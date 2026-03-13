local utils = require("ide.utils")
local pack = require("ide.pack")

--- MODULE DEFINITION ----------------------------------------------------------
local M = {}
local I = {}

---@type ide.Opts.Lint
I.opts = {}
---@type table<string, boolean>
I.configured_ft = {}

--- Nvim-lint specific configurator
---@param opts ide.Opts.Lint
function M.setup(opts)
    I.opts = opts or {}
    utils.run.on_load("nvim-lint", function()
        require("editorconfig").properties.tools_inspect = M.handle_tools_inspect_declaration
        local lint = require("lint")
        I.merge_linters(opts.linters and opts.linters or {})
        lint.linters_by_ft = utils.tool.resolve_by_ft(opts.linters_by_ft)
        -- In case we don't have tools_inspect in .editorconfig we still want to configure LSP clients
        utils.autocmd.create("BufReadPost", {
            group = "ide-lint",
            callback = function(e)
                local filetype = vim.api.nvim_get_option_value("filetype", { buf = e.buf })
                if I.configured_ft[filetype] then
                    return
                end

                M.handle_tools_inspect_declaration(e.buf, "", {})
            end,
        })
    end, "Failed to setup ide.Lint due to: ")
end

--- Handling editorconfig integration for tools_inspect property
---@param bufnr integer
---@param val string
---@param opts? table
function M.handle_tools_inspect_declaration(bufnr, val, opts)
    utils.run.on_load("nvim-lint", function()
        local ft = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
        if I.configured_ft[ft] then
            return
        end
        local lnt = require("lint")

        local tools = vim.iter(vim.split(val, ",", { plain = true, trimempty = true }))
            :filter(function(v)
                return v ~= ""
            end)
            :totable()

        lnt.linters_by_ft[ft] = lnt.linters_by_ft[ft] or {}

        -- Iterate over both tools configured in ide and in .editorconfig
        vim.list_extend(tools, lnt.linters_by_ft[ft])

        local add = {}
        local remove = {}

        for _, tool in ipairs(tools) do
            local enable = tool:sub(1, 1) ~= "!"
            local name = tool:sub(enable and 1 or 2)
            if not enable or lnt.linters[name] == nil then
                vim.list_extend(remove, { name })
            else
                vim.list_extend(add, { name })
            end
        end

        lnt.linters_by_ft[ft] = utils.table.list_add_rem(lnt.linters_by_ft[ft], add, remove)

        for _, tool in ipairs(lnt.linters_by_ft[ft]) do
            local name = tool
            local command = lnt.linters[name].cmd
            local can_run, binary = utils.run.can_run_command(command)
            if can_run then
                lnt.linters_by_ft[ft] = utils.table.list_add_rem(lnt.linters_by_ft[ft], { name }, {})
            elseif vim.fn.executable("nix") then
                -- Removing it for now until we get nix command to run it
                lnt.linters_by_ft[ft] = utils.table.list_add_rem(lnt.linters_by_ft[ft], {}, { name })
                -- TODO: add set up process status into statusline
                local nix_pkg = (lnt.linters[name] --[[@as ide.Linter]] or {}).nix_pkg or binary
                utils.run.get_nix_cmd({ pkg = nix_pkg, program = binary }, function(nix_cmd, o)
                    if o.code == 0 then
                        -- `nix` is cmd now
                        lnt.linters[name].cmd = table.remove(nix_cmd, 1)
                        -- Prepend args with nix command (`run --impure ..` or `shell --impure ..`)
                        lnt.linters[name].args = vim.list_extend(nix_cmd, lnt.linters[name].args or {})

                        lnt.linters_by_ft[ft] = utils.table.list_add_rem(lnt.linters_by_ft[ft], { name }, {})

                        -- Runs linter after it is configured if file type matches
                        if string.match(vim.api.nvim_buf_get_name(0), "%." .. ft .. "$") ~= nil then
                            lnt.try_lint({ name })
                        end
                    else
                        lnt.linters_by_ft[ft] = utils.table.list_add_rem(lnt.linters_by_ft[ft], {}, { name })
                    end
                end)
            end
        end

        -- We are ignoring errors here because some of the linters might not have their binaries configured
        lnt.try_lint(nil, { ignore_errors = true })

        I.configured_ft[ft] = true
        I.create_ft_autocmds(string.format("*.%s", ft))
    end, "Failed to configure tools_inspect due to: ")
end

--- Merges the provided linters into nvim-lint's existing linters.
--- NOTE: run this only when nvim-lint is loaded
---@param linters table<string, ide.Linter|fun():ide.Linter>
function I.merge_linters(linters)
    vim.validate("linters", linters, { "table" }, "Linters must be a table")
    assert(pack.is_loaded("nvim-lint"), "nvim-lint must be loaded before merging linters")

    local lint = require("lint")
    for linter_name, linter_opts in pairs(linters) do
        vim.validate("linter_opts", linter_opts, { "table", "function" }, "Linter must be a table or a function")
        if type(linter_opts) == "fuction" then
            lint.linters[linter_name] = linter_opts()
        else
            local linter = lint.linters[linter_name]
            if type(linter) == "function" then
                linter = linter()
            end
            lint.linters[linter_name] = vim.tbl_deep_extend("force", linter or {}, linter_opts)
        end
    end
end

function I.create_ft_autocmds(pattern)
    -- TODO: move debounce from kdtsk to ide utils
    -- Run linters that require a file to be saved and stdin
    utils.autocmd.create({ "BufWritePost", "BufReadPre", "BufNewFile" }, {
        group = "ide-lint-write",
        pattern = pattern,
        callback = Utils.debounce(100, function()
            require("lint").try_lint()
        end),
    }, { clear = false })
    -- Run linters that use stdin
    utils.autocmd.create({ "InsertLeave", "TextChanged" }, {
        group = "ide-lint-stdin",
        pattern = pattern,
        callback = Utils.debounce(100, function()
            require("lint").try_lint(nil, { filter = "stdin" })
        end),
    }, { clear = false })
end

return M

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
    I.opts.linters = I.opts.linters or {}
    I.opts.linters_by_ft = I.opts.linters_by_ft or {}

    utils.run.on_load("nvim-lint", function()
        require("editorconfig").properties.tools_inspect = M.handle_tools_inspect_declaration
        I.merge_linters(I.opts.linters)
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
        local resolved = utils.tool.resolve((I.opts.linters_by_ft or {})[ft] or {})
        local add, remove = utils.tool.parse_tools(val)

        lnt.linters_by_ft[ft] = utils.table.list_add_rem(utils.tool.extract_names(resolved), add, remove)
        lnt.linters_by_ft[ft] = vim.iter(lnt.linters_by_ft[ft])
            :filter(function(name)
                return lnt.linters[name] ~= nil
            end)
            :totable()

        for _, name in ipairs(lnt.linters_by_ft[ft]) do
            local command = lnt.linters[name].cmd
            local can_run, binary = utils.run.can_run_command(command)
            if not can_run and vim.fn.executable("nix") then
                -- Removing it for now until we get nix command to run it
                lnt.linters_by_ft[ft] = utils.table.list_add_rem(lnt.linters_by_ft[ft], {}, { name })
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

        if #lnt.linters_by_ft[ft] > 0 then
            -- We are ignoring errors here because some of the linters might not have their binaries configured
            lnt.try_lint(lnt.linters_by_ft[ft], { ignore_errors = true })
        end

        I.configured_ft[ft] = true
        I.create_ft_autocmds(string.format("*.%s", ft))
    end, "Failed to configure tools_inspect due to: ")
end

-- Overrides for nvim-lint
M.linters = {
    -- PHP Code Sniffer
    phpcs = { ---@type ide.Linter
        cmd = function()
            return utils.tool.find_php_executable("phpcs") or "phpcs"
        end,
        nix_pkg = "php85Packages.php-codesniffer",
        -- Sets col and end_col to whole row
        parser = function(output, bufnr)
            local severities = {
                ERROR = vim.diagnostic.severity.ERROR,
                WARNING = vim.diagnostic.severity.WARN,
            }

            local bin = "phpcs"
            if vim.trim(output) == "" or output == nil then
                return {}
            end

            local diagnostics = {}
            local decoded = vim.json.decode(output)
            for _, result in pairs(decoded.files) do
                for _, msg in ipairs(result.messages or {}) do
                    local lnum = type(msg.line) == "number" and (msg.line - 1) or 0
                    local linecont = vim.api.nvim_buf_get_lines(bufnr, lnum, lnum + 1, false)[1] or ""
                    local col = linecont:match("()%S") or 1
                    local end_col = linecont:match(".*%S()") or 1
                    table.insert(diagnostics, {
                        lnum = lnum,
                        col = col - 1,
                        end_col = end_col,
                        message = msg.message,
                        code = msg.source,
                        source = bin,
                        severity = assert(severities[msg.type], "missing mapping for severity " .. msg.type),
                    })
                end
            end
            return diagnostics
        end,
    },

    -- PHP Mess Detector
    phpmd = { ---@type ide.Linter
        cmd = function()
            return utils.tool.find_php_executable("phpmd") or "phpmd"
        end,
        args = {
            "-",
            "json",
            "./phpmd.xml",
        },
        nix_pkg = "php84Packages.phpmd",
        -- Adds this only to strip deprecations from output
        parser = function(output, _)
            local bin = "phpmd"
            local severities = {}
            severities[1] = vim.diagnostic.severity.ERROR
            severities[2] = vim.diagnostic.severity.WARN
            severities[3] = vim.diagnostic.severity.INFO
            severities[4] = vim.diagnostic.severity.HINT
            severities[5] = vim.diagnostic.severity.HINT

            if vim.trim(output) == "" or output == nil then
                return {}
            end

            local ok
            ok, output = Utils.linter_phpmd.strip_deprecations(output)

            if not vim.startswith(output, "{") or not ok then
                vim.notify(output)
                return {}
            end

            local decoded = vim.json.decode(output)
            local diagnostics = {}
            local messages = {}

            if decoded["files"] and decoded["files"][1] and decoded["files"][1]["violations"] then
                messages = decoded["files"][1]["violations"]
            end

            for _, msg in ipairs(messages or {}) do
                table.insert(diagnostics, {
                    lnum = msg.beginLine - 1,
                    end_lnum = msg.endLine - 1,
                    col = 0,
                    end_col = 0,
                    message = msg.description,
                    code = msg.rule,
                    source = bin,
                    severity = assert(severities[msg.priority], "missing mapping for severity " .. msg.priority),
                })
            end

            return diagnostics
        end,
    },

    -- PHPStan
    phpstan = { ---@type ide.Linter
        cmd = function()
            return utils.tool.find_php_executable("phpstan") or "phpstan"
        end,
        nix_pkg = "php84Packages.phpstan",
        -- Sets col and end_col to whole row
        parser = function(output, bufnr)
            if vim.trim(output) == "" or output == nil then
                return {}
            end

            local file = vim.json.decode(output).files[vim.api.nvim_buf_get_name(bufnr)]

            if file == nil then
                return {}
            end

            local diagnostics = {}

            for _, message in ipairs(file.messages or {}) do
                local lnum = type(message.line) == "number" and (message.line - 1) or 0
                local linecont = vim.api.nvim_buf_get_lines(bufnr, lnum, lnum + 1, false)[1] or ""
                local col = linecont:match("()%S") or 0
                local end_col = linecont:match(".*%S()") or 0
                table.insert(diagnostics, {
                    lnum = lnum,
                    col = col - 1,
                    end_col = end_col - 1,
                    code = message.identifier and message.identifier or "", -- only works for phpstan >= 1.11
                    message = message.message .. (message.tip and "\n---\nTip: " .. message.tip .. "\n" or ""),
                    source = "phpstan",
                    severity = vim.diagnostic.severity.ERROR,
                })
            end

            return diagnostics
        end,
    },

    -- Psalm
    psalm = { ---@type ide.Linter
        cmd = function()
            return utils.tool.find_php_executable("psalm") or "psalm"
        end,
        nix_pkg = "php84Packages.psalm",
        -- Psalm exits with 2 when there are issues in file
        ignore_exitcode = true,
        -- Adds type, link and shortcote to diagnostics entries
        parser = function(output, bufnr)
            if output == nil then
                return {}
            end

            local filename = vim.api.nvim_buf_get_name(bufnr)

            local messages = vim.json.decode(output)
            local diagnostics = {}

            for _, message in ipairs(messages or {}) do
                if message.file_path == filename then
                    table.insert(diagnostics, {
                        lnum = message.line_from - 1,
                        end_lnum = message.line_to - 1,
                        col = message.column_from - 1,
                        end_col = message.column_to - 1,
                        message = message.message,
                        code = message.type .. " " .. message.link,
                        source = "psalm",
                        severity = message.severity,
                    })
                end
            end

            return diagnostics
        end,
    },
}

--- Merges the provided linters into nvim-lint's existing linters.
--- NOTE: run this only when nvim-lint is loaded
---@param linters table<string, ide.Linter|fun():ide.Linter>
function I.merge_linters(linters)
    vim.validate("linters", linters, { "table" }, "Linters must be a table")
    assert(pack.is_loaded("nvim-lint"), "nvim-lint must be loaded before merging linters")

    local lint = require("lint")
    for linter_name, linter_opts in pairs(linters) do
        vim.validate("linter_opts", linter_opts, { "table", "function" }, "Linter must be a table or a function")
        if type(linter_opts) == "function" then
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
    -- Run linters that require a file to be saved and stdin
    utils.autocmd.create({ "BufWritePost", "BufReadPre", "BufNewFile" }, {
        group = "ide-lint-write:" .. pattern,
        pattern = pattern,
        callback = utils.run.debounce(100, function()
            require("lint").try_lint()
        end),
    })
    -- Run linters that use stdin
    utils.autocmd.create({ "InsertLeave", "TextChanged" }, {
        group = "ide-lint-stdin:" .. pattern,
        pattern = pattern,
        callback = utils.run.debounce(100, function()
            require("lint").try_lint(nil, { filter = "stdin" })
        end),
    })
end

return M

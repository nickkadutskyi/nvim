local utils = require("ide.utils")
local pack = require("ide.pack")

--- MODULE DEFINITION ----------------------------------------------------------
local M = {}
local I = {}

---@type ide.Opts.Conform
I.opts = {}

---@param opts ide.Opts.Conform
function M.setup(opts)
    I.opts = opts or {}
    utils.run.on_load("conform.nvim", function()
        require("editorconfig").properties.tools_style = M.handle_tools_style_declartion
        local cnfm = require("conform")

        -- Conform.nvim merges `formatters_by_ft` and `formatters` for me
        cnfm.setup(opts.conform_opts or {})
        utils.autocmd.create("BufReadPost", {
            group = "ide-conform",
            callback = function(e)
                local filetype = vim.api.nvim_get_option_value("filetype", { buf = e.buf })
                if I.configured_ft[filetype] then
                    return
                end

                M.handle_tools_style_declartion(e.buf, "", {})
            end,
        })
    end)
end

I.configured_ft = {}

--- Handling editorconfig integration for tools_style property
---@type fun(bufnr: integer, val: string, opts?: table)
function M.handle_tools_style_declartion(bufnr, val, _)
    utils.run.on_load("conform.nvim", function()
        local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
        if I.configured_ft[filetype] then
            return
        end
        local cnfm = require("conform")

        local tools = vim.iter(vim.split(val, ",", { plain = true, trimempty = true }))
            :filter(function(v)
                return v ~= ""
            end)
            :totable()

        local add = {}
        local remove = {}
        for _, tool in ipairs(tools) do
            vim.validate("tool", tool, "string", "non-empty string")
            local enable = tool:sub(1, 1) ~= "!"
            local name = tool:sub(enable and 1 or 2)
            if not enable then
                vim.list_extend(remove, { name })
            else
                vim.list_extend(add, { name })
            end
        end
        if #add > 0 then
            cnfm.setup({ formatters_by_ft = { [filetype] = add } })
        end
        if #add > 0 or #remove > 0 then
            vim.iter(I.opts.formatters_by_ft):each(function(_, formatters)
                vim.iter(formatters):each(function(v)
                    if vim.tbl_contains(add, v[1]) then
                        v[4] = true
                    end
                    if vim.tbl_contains(remove, v[1]) then
                        v[4] = false
                    end
                end)
            end)
        end

        cnfm.setup({ formatters_by_ft = utils.tool.resolve_by_ft(I.opts.formatters_by_ft) })

        for _, formatter_names in pairs(cnfm.formatters_by_ft) do
            if type(formatter_names) ~= "function" then
                -- Don't handle if it's a function because it requires parameters provided by conform.nvim
                for _, name in ipairs(formatter_names) do
                    local info = cnfm.get_formatter_info(name)
                    local config = cnfm.get_formatter_config(name)
                    -- Only handle if formatter is not available
                    if config ~= nil and not info.available then
                        local command = config.command
                        -- If command is a function it might require params provided by conform.nvim so run it safely
                        if type(command) == "function" then
                            local ok, cmd = pcall(command)
                            command = ok and cmd or ((config.options or {}).cmd or name)
                        end
                        -- Resolve binary for the command
                        local can_run, binary = utils.run.can_run_command(command)
                        -- If `can_run` is true do nothing since it's already in the configs
                        -- and will be run on reformatting action
                        -- If not runnable directly and not available in Nix then do nothing and let it fail

                        -- If not runnable directly and has nix than use nix to run it
                        if not can_run and vim.fn.executable("nix") then
                            local nix_pkg = (config.options or {}).nix_pkg or binary
                            utils.run.get_nix_cmd({ pkg = nix_pkg, program = binary }, function(nix_cmd, o)
                                if o.code == 0 then
                                    cnfm.formatters[name] = cnfm.formatters[name] or {}
                                    cnfm.formatters[name].command = table.remove(nix_cmd, 1)
                                    cnfm.formatters[name].prepend_args = nix_cmd
                                end
                            end)
                        end
                    end
                end
            end
        end

        I.configured_ft[filetype] = true
    end, "Failed to configure tools_style due to: ")
end

return M

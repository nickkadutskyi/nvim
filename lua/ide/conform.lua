local utils = require("ide.utils")
local pack = require("ide.pack")

--- MODULE DEFINITION ----------------------------------------------------------
local M = {}
local I = {}

---@type ide.Opts.Conform
I.opts = {}
---@type table<string, boolean>
I.configured_ft = {}

--- Conform.nvim specific config
---@param opts ide.Opts.Conform
function M.setup(opts)
    I.opts = opts or {}
    I.opts.formatters_by_ft = I.opts.formatters_by_ft or {}
    I.opts.conform_opts = I.opts.conform_opts or {}

    utils.run.on_load("conform.nvim", function()
        require("editorconfig").properties.tools_style = M.handle_tools_style_declartion
        local cnfm = require("conform")

        -- Conform.nvim merges `formatters_by_ft` and `formatters` for me
        cnfm.setup(I.opts.conform_opts)
        -- In case we don't have tools_style in .editorconfig we still want to configure LSP clients
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

--- Handling editorconfig integration for tools_style property
---@type fun(bufnr: integer, val: string, opts?: table)
function M.handle_tools_style_declartion(bufnr, val, _)
    utils.run.on_load("conform.nvim", function()
        local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
        if I.configured_ft[filetype] then
            return
        end

        local cnfm = require("conform")

        local add, remove = utils.tool.parse_tools(val)
        vim.iter(I.opts.formatters_by_ft[filetype] or {}):each(function(v)
            if vim.tbl_contains(add, v[1]) then
                v[4] = true
            elseif vim.tbl_contains(remove, v[1]) then
                v[4] = false
            end
        end)
        local resolved = utils.tool.resolve((I.opts.formatters_by_ft or {})[filetype] or {})
        local names = utils.table.list_add_rem(utils.tool.extract_names(resolved), add, remove)
        local ft_config = I.build_ft_config(resolved, names)

        cnfm.setup({ formatters_by_ft = { [filetype] = ft_config } })

        if type(ft_config) ~= "function" then
            -- Don't handle if it's a function because it requires parameters provided by conform.nvim
            for _, name in ipairs(ft_config) do
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

        I.configured_ft[filetype] = true
    end, "Failed to configure tools_style due to: ")
end

---@param resolved table
---@param names string[]
---@return table
function I.build_ft_config(resolved, names)
    local config = vim.list_extend({}, names)
    for key, value in pairs(resolved or {}) do
        if type(key) ~= "number" then
            config[key] = value
        end
    end
    return config
end

return M

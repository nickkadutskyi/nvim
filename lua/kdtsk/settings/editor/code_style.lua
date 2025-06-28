-- Handled via .editorconfig
-- vim.opt.textwidth = 120 -- max_line_length
vim.opt.tabstop = 2 -- tab_width
vim.opt.expandtab = true -- indent_style
-- vim.opt.fileencoding = "utf-8" -- is set automatically
vim.opt.softtabstop = 2 -- indent_size
vim.opt.shiftwidth = 2 -- indent_size

-- Indents next line if current is indented
vim.opt.autoindent = true
vim.opt.smartindent = true
-- Allow to move to one column past the end of the line
vim.opt.virtualedit = "onemore"

---@type LazySpec
return {
    { -- Code formatting configuration
        "stevearc/conform.nvim",
        event = "VeryLazy",
        ---@type conform.setupOpts
        opts = {
            format_on_save = {
                timeout_ms = 500,
            },
            default_format_opts = {
                stop_after_first = true,
            },
            formatters = {
                prettier = {
                    options = {
                        nix_pkg = "nodePackages_latest.prettier",
                    },
                    ---@param self conform.FormatterConfig
                    ---@param ctx conform.Context
                    prepend_args = function(self, ctx)
                        local args = {}
                        if ctx.filename:match("%.xml$") then
                            -- Plugin for XML have to be installed
                            vim.list_extend(args, { "--plugin=@prettier/plugin-xml" })
                        end
                        return args
                    end,
                },
            },
        },
        ---@param opts? conform.setupOpts
        config = function(_, opts)
            local utils = require("kdtsk.utils")
            local conform = require("conform")

            -- Conform.nvim merges `formatters_by_ft` and `formatters` for me
            conform.setup(opts)

            -- Ensures binaries are present and reconfigure formatters if needed
            for _, formatter_names in pairs(conform.formatters_by_ft) do
                -- Doesn't handle if it's a function because it requires parameters provided by conform.nvim
                if type(formatter_names) == "function" then
                    formatter_names = {}
                end

                for _, name in ipairs(formatter_names) do
                    local info = conform.get_formatter_info(name)
                    local config = conform.get_formatter_config(name)

                    -- Only handle if formatter is not available
                    if config ~= nil and not info.available then
                        local command = config.command
                        -- If command is a function it might require params provided by conform.nvim so run it safely
                        if type(command) == "function" then
                            local ok, cmd = pcall(command)
                            command = ok and cmd or ((config.options or {}).cmd or name)
                        end

                        -- Ensure binary for the command
                        local via_nix, _, _ = utils.handle_commands({ [name] = command })
                        if not vim.tbl_isempty(via_nix) then
                            local nix_pkg = (config.options or {}).nix_pkg or via_nix[name]
                            utils.cmd_via_nix(nix_pkg, command, function(nix_cmd, o)
                                if o.code == 0 then
                                    conform.formatters[name] = conform.formatters[name] or {}
                                    conform.formatters[name].command = table.remove(nix_cmd, 1)
                                    conform.formatters[name].prepend_args = nix_cmd
                                end
                            end)
                        end
                    end
                end
            end

            -- Keymap
            vim.keymap.set({ "n", "v" }, "<leader>rc", require("conform").format, {
                desc = "Code: [r]eformat [c]ode",
            })
        end,
    },
}

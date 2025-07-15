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
                timeout_ms = 1500,
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
            local conform = require("conform")

            -- Conform.nvim merges `formatters_by_ft` and `formatters` for me
            conform.setup(opts)

            -- Ensures binaries are present and reconfigure formatters if needed
            for _, formatter_names in pairs(conform.formatters_by_ft) do
                -- Don't handle if it's a function because it requires parameters provided by conform.nvim
                if type(formatter_names) ~= "function" then
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

                            -- Resolve binary for the command
                            local run_directly, run_via_nix, binary = Utils.tools.run_command_via(command)
                            -- If `run_directly` is true do nothing since it's already in the configs
                            -- and will be run on reformatting action
                            -- If not runnable directly and not available in Nix then do nothing and jet it fail

                            -- If not runnable directly and outside of Nix shell then use Nix to run it
                            if run_via_nix then
                                local nix_pkg = (config.options or {}).nix_pkg
                                    or (config.options or {}).nix_pkgs
                                    or binary
                                Utils.nix.get_cmd_via_nix(nix_pkg, command, function(nix_cmd, o)
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
            end

            -- Keymap
            vim.keymap.set({ "n", "v" }, "<leader>rc", require("conform").format, {
                desc = "Code: [r]eformat [c]ode",
            })
        end,
    },
}

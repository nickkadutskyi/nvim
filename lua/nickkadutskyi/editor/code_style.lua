---Config
-- Soft wrap
vim.opt.wrap = false
-- Soft wrap at line break - disabled for now
vim.opt.linebreak = false
-- Better indentation for wrapped lines
if vim.fn.has("linebreak") == 1 then
    vim.opt.breakindent = true
    vim.opt.showbreak = "↳ "
    vim.opt.breakindentopt = { shift = 0, min = 20, sbr = true }
end

-- Handled via .editorconfig
-- vim.opt.textwidth = 120 -- max_line_length
vim.opt.tabstop = 2 -- tab_width
vim.opt.expandtab = true -- indent_style
vim.opt.fileencoding = "utf-8" -- charset
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
        dependencies = {
            "mason.nvim",
            "zapling/mason-conform.nvim",
            "WhoIsSethDaniel/mason-tool-installer.nvim",
        },
        opts = {
            default_format_opts = {
                lsp_format = "fallback",
                stop_after_first = true,
            },
        },
        ---@param opts? conform.setupOpts
        config = function(_, opts)
            local utils = require("nickkadutskyi.utils")
            local conform = require("conform")

            -- Gets mason-nvim-lint
            local has_mcmap, mcmap = pcall(require, "mason-conform.mapping")
            local mason_map = has_mcmap and mcmap.conform_to_package or {}
            local has_minstaller, minstaller = pcall(require, "mason-tool-installer")
            local ensure_installed_via_mason = {}

            conform.setup(opts)

            for _, formatter_names in pairs(conform.formatters_by_ft) do
                -- Doesn't handle if it's a function
                if type(formatter_names) == "function" then
                    formatter_names = {}
                end
                for _, name in ipairs(formatter_names) do
                    local info = conform.get_formatter_info(name)
                    local config = conform.get_formatter_config(name)
                    if config ~= nil and not info.available then
                        local command = config.command
                        if type(command) == "function" then
                            local ok, cmd = pcall(command)
                            command = ok and cmd or ((config.options or {}).cmd or name)
                        end
                        local via_mason, via_nix, _, _ = utils.handle_commands({ [name] = command }, mason_map)
                        if not vim.tbl_isempty(via_mason) then
                            vim.list_extend(ensure_installed_via_mason, { mason_map[name] })
                        elseif not vim.tbl_isempty(via_nix) then
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

            if has_minstaller then
                minstaller.setup({
                    ensure_installed = ensure_installed_via_mason,
                })
            end

            -- Keymap
            vim.keymap.set({ "n", "v" }, "<leader>rc", require("conform").format, {
                desc = "Code: [r]eformat [c]ode",
            })
        end,
    },
}

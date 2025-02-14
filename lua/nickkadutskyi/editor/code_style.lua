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
        dependencies = { "mason.nvim" },
        opts = {
            default_format_opts = {
                lsp_format = "fallback",
                stop_after_first = true,
            },
        },
        config = function(_, opts)
            local conform = require("conform")
            conform.setup(opts)

            -- If Nix is available then ensure at least one formatter for each filetype
            local nix_path = vim.fn.exepath("nix")
            if #nix_path ~= 0 then
                for _, formatters in pairs(conform.formatters_by_ft) do
                    local cmd_formatter = nil
                    for ind, formatter_name in
                        ipairs(formatters --[=[@as string[]]=])
                    do
                        local formatter_info = conform.get_formatter_info(formatter_name)
                        local formatter_config = conform.get_formatter_config(formatter_name)
                        if formatter_config ~= nil then
                            formatter_config.options = formatter_config.options or {}
                            if
                                formatter_config
                                and formatter_config.command
                                and formatter_config.options.nix_pkg
                                and cmd_formatter == nil
                            then
                                cmd_formatter = formatter_config
                                cmd_formatter.options.name = formatter_name
                            end
                            if formatter_info.available then
                                break
                            elseif ind == #formatters and cmd_formatter then
                                conform.formatters[cmd_formatter.options.name].command = "nix"
                                conform.formatters[cmd_formatter.options.name].prepend_args = {
                                    "run",
                                    "nixpkgs#" .. cmd_formatter.options.nix_pkg,
                                    "--",
                                }
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

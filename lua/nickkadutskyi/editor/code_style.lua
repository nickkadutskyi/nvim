-- Soft wrap
vim.opt.wrap = false
-- Soft wrap at linebreak
vim.opt.linebreak = false
-- Better indentation for wrapped lines
if vim.fn.has("linebreak") == 1 then
    vim.opt.breakindent = true
    vim.opt.showbreak = "↳ "
    vim.opt.breakindentopt = { shift = 0, min = 20, sbr = true }
end
-- Hard wrap -- Better handle this via formatters and .editorconfig rules
-- vim.opt.textwidth = 120
-- Set the tab size to 2 spaces
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
-- Use spaces instead of tabs
vim.opt.expandtab = true
-- Indents next line if current is indented
vim.opt.autoindent = true
vim.opt.smartindent = true
-- Adds visual guides
-- vim.opt.colorcolumn = "80,100,120" -- defined in plugin
-- Allow to move to one column past the end of the line
vim.opt.virtualedit = 'onemore'

-- Lazy.nvim module
return {
    {
        -- Initializes conform.nvim fro code formatting
        "stevearc/conform.nvim",
        opts = {
            default_format_opts = {
                lsp_format = "fallback",
                stop_after_first = true,
            },
        },
        config = function(_, opts)
            local conform = require("conform")

            conform.setup(opts)
            vim.keymap.set("n", "<leader>rc", conform.format, {
                noremap = true,
                desc = "Code: [r]eformat [c]ode",
            })
        end,
    },
    {
        -- Adjusts tab size automatically
        "tpope/vim-sleuth",
    },
}

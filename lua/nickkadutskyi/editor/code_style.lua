-- Soft wrap
vim.opt.wrap = false
-- Soft wrap at linebreak - disabled for now
vim.opt.linebreak = false
-- Better indentation for wrapped lines
if vim.fn.has("linebreak") == 1 then
    vim.opt.breakindent = true
    vim.opt.showbreak = "↳ "
    vim.opt.breakindentopt = { shift = 0, min = 20, sbr = true }
end

-- Handled via .editorconfig
-- vim.opt.textwidth = 120 -- max_line_length
-- vim.opt.tabstop = 2 -- tab_width
-- vim.opt.expandtab = true -- indent_style
-- vim.opt.fileencoding = "utf-8" -- charset
-- vim.opt.softtabstop = 2 -- indent_size
-- vim.opt.shiftwidth = 2 -- indent_size

-- Indents next line if current is indented
vim.opt.autoindent = true
vim.opt.smartindent = true
-- Allow to move to one column past the end of the line
vim.opt.virtualedit = "onemore"

-- Lazy.nvim module
return {
    {
        -- Initializes conform.nvim fro code formatting
        "stevearc/conform.nvim",
        -- Merged with nickkadutskyi.lanaguages_frameworks
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
        "zapling/mason-conform.nvim",
        enabled = false,
        dependencies = { "williamboman/mason.nvim", "stevearc/conform.nvim" },
        -- ignore_install is merged from nickkadutskyi.languages_frameworks
        opts = { ignore_install = {} },
        config = true,
    },
}

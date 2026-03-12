local spec_builder = require("ide.spec.builder")

--- OPTIONS --------------------------------------------------------------------
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

--- PLUGINS --------------------------------------------------------------------

spec_builder.add({
    {
        "virt-column.nvim",
        opts = {
            -- Highlight groups from kdtsk/jb.nvim
            highlight = {
                "General_Editor_Guides_VisualGuides",
                "General_Editor_Guides_VisualGuides",
                "General_Editor_Guides_HardWrapGuide",
            },
            char = "▕",
            virtcolumn = "80,100,120",
            exclude = { filetypes = { "netrw" } },
        },
    },
})

-- Show line nubmers
vim.opt.number = true
-- Show line nubmers relative to the cursor position
vim.opt.relativenumber = true
-- Sets how neovim will display certain whitespace characters in the editor.
vim.opt.list = true
vim.opt.listchars = {
    tab = "» ",
    space = "‧",
    trail = "‧",
    extends = "⟩",
    nbsp = "␣",
}
-- Enables cursor line highlight groups
vim.opt.cursorline = true
-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 3

return {
    {
        -- Visual guides
        "lukas-reineke/virt-column.nvim",
        opts = {
            -- Use highlight groups from nickkadutskyi/jb.nvim
            highlight = {
                "General_Editor_Guides_VisualGuides",
                "General_Editor_Guides_VisualGuides",
                "General_Editor_Guides_HardWrapGuide",
            },
            char = "▕",
            virtcolumn = "80,100,120",
        },
    },
    {
        -- Indent guides
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        opts = {
            indent = { char = "▏" },
            scope = {
                -- disables underline
                show_start = false,
                show_end = false,
            },
        },
    },
    {
        -- Scrollbar to also show git changes not visible in current view
        "petertriho/nvim-scrollbar",
        dependencies = {
            "kevinhwang91/nvim-hlslens",
        },
        opts = {
            show = true,
            set_highlights = false,
            hide_if_all_visible = true,
            handlers = {
                diagnostic = true,
                gitsigns = true, -- Requires gitsigns
                handle = true,
                search = true, -- Requires hlslens
                cursor = false,
            },
            marks = {
                GitAdd = {
                    text = "│",
                },
                GitChange = {
                    text = "│",
                },
            },
        },
    },
}

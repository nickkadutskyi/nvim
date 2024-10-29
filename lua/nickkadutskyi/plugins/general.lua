return {
    {
        -- Improves commenting
        "numToStr/Comment.nvim",
        opts = {},
        lazy = false,
    },
    {
        -- Gutter or statusline icons, requires a Nerd Font.
        "nvim-tree/nvim-web-devicons",
        config = function()
            require("nvim-web-devicons").setup({
                override = { -- your personnal icons can go here (to override)
                    zsh = { icon = "", color = "#428850", cterm_color = "65", name = "Zsh" },
                },
                default = true, -- globally enable default icons (default to false)
                strict = true, -- globally enable "strict" selection of icons (default to false)
                override_by_filename = { -- same as `override` but for overrides by filename (requires `strict` to be true)
                    [".gitignore"] = { icon = "", color = "#f1502f", name = "Gitignore" },
                },
                override_by_extension = { -- same as `override` but for overrides by extension (requires `strict` to be true)
                    ["log"] = { icon = "", color = "#81e043", name = "Log" },
                },
            })
        end,
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
        -- config = function()
        --     require("scrollbar").setup({
        --         handlers = {
        --             cursor = true, -- to show my position in doc
        --             gitsigns = true, -- to see if I have any changes
        --             handle = false, -- disables handle because it works shitty
        --         },
        --         marks = {
        --             GitAdd = {
        --                 text = "│",
        --             },
        --             GitChange = {
        --                 text = "│",
        --             },
        --         },
        --     })
        --     require("scrollbar.handlers.gitsigns").setup()
        -- end,
    },
}

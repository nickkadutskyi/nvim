---@type LazySpec
return {
    { -- Gutter or statusline icons, requires a Nerd Font.
        "nvim-tree/nvim-web-devicons",
        config = function()
            require("nvim-web-devicons").setup({
                override = { -- your personal icons can go here (to override)
                    zsh = {
                        icon = "",
                        color = "#428850",
                        cterm_color = "65",
                        name = "Zsh",
                    },
                },
                -- globally enable default icons (default to false)
                default = true,
                -- globally enable "strict" selection of icons
                -- (default to false)
                strict = true,
                -- same as `override` but for overrides by filename
                -- (requires `strict` to be true)
                override_by_filename = {
                    [".gitignore"] = {
                        icon = "",
                        color = "#f1502f",
                        name = "Gitignore",
                    },
                },
                -- same as `override` but for overrides by extension
                -- (requires `strict` to be true)
                override_by_extension = {
                    ["js"] = {
                        icon = "",
                        color = "#CBCB41",
                        cterm_color = "185",
                        name = "Js",
                    },
                    ["php"] = {
                        -- icon = " ",
                        icon = "󰌟",
                        color = "#3E7BE9",
                        cterm_color = "33",
                        name = "Php",
                    },
                    ["log"] = {
                        icon = "",
                        color = "#81e043",
                        name = "Log",
                    },
                },
            })
        end,
    },
}

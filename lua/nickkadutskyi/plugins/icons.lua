return {
    {
        -- For getting pretty icons, but requires a Nerd Font.
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
}

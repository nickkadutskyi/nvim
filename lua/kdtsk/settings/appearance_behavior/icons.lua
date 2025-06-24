---@type LazySpec
return {
    { -- Gutter or statusline icons, requires a Nerd Font.
        "nvim-tree/nvim-web-devicons",
        dependencies = {
            "nickkadutskyi/jb.nvim",
        },
        opts = {
            default = false,
            strict = true,
            color_icons = true,
            override = { -- your personal icons can go here (to override)
                zsh = {
                    icon = "",
                    color = "#428850",
                    cterm_color = "65",
                    name = "Zsh",
                },
            },
        },
        config = function(_, opts)
            -- Load icons from jb.nvim
            opts.override_by_filename = Utils.icons.files.by_filename
            opts.override_by_extension = Utils.icons.files.by_extension

            -- Extracts light and dark variants of icons from jb.nvim
            local light_variants = {}
            local dark_variants = {}
            for _, icons in pairs(Utils.icons.files) do
                ---@type table<string, jb.Icon>
                for identifier, icon in pairs(icons) do
                    light_variants[identifier] = {
                        icon = icon.icon,
                        color = icon.light and icon.light.color or icon.color or nil,
                        cterm_color = icon.light and icon.light.cterm_color or icon.cterm_color or nil,
                        name = icon.name,
                    }
                    dark_variants[identifier] = {
                        icon = icon.icon,
                        color = icon.dark and icon.dark.color or icon.color or nil,
                        cterm_color = icon.dark and icon.dark.cterm_color or icon.cterm_color or nil,
                        name = icon.name,
                    }
                end
            end

            local devicons = require("nvim-web-devicons")
            -- Run this function to apply icons based on the current background
            local function apply_theme_icons()
                devicons.set_icon(vim.o.background == "light" and light_variants or dark_variants)
            end

            devicons.setup(opts)
            apply_theme_icons()

            -- Set icons every time the background option changes
            vim.api.nvim_create_autocmd("OptionSet", {
                group = vim.api.nvim_create_augroup("kdtsk-sync-icons-with-bg", { clear = true }),
                pattern = "background",
                callback = function()
                    vim.defer_fn(apply_theme_icons, 10)
                end,
            })
        end,
    },
}

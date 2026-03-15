local spec = require("ide.spec.builder")

--- PLUGINS --------------------------------------------------------------------

spec.add({
    "nvim-web-devicons",
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
})

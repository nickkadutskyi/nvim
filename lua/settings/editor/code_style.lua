local spec_builder = require("ide.spec.builder")

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

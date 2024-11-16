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
        },
    },
    -- Loads configs for each language
    { import = "nickkadutskyi.editor.code_style" },
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
            -- TODO change to [f]ormat [c]ode
            vim.keymap.set("n", "<leader>cf", conform.format, { noremap = true, desc = "[c]ode [f]ormat" })
        end,
    },
}

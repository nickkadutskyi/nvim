return { -- Scrollbar to also show git changes not visible in current view
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
}

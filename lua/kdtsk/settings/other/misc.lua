---@type LazySpec
return {
    { -- Snacks.nvim version of bigfile
        "folke/snacks.nvim",
        ---@type snacks.Config
        opts = {
            ---@class snacks.bigfile.Config
            bigfile = { enabled = true },
            -- Moves git status to the right side of the row numbers like in IntelliJ
            statuscolumn = {
                enabled = true,
                folds = {
                    open = true, -- show open fold icons
                    git_hl = true, -- use Git Signs hl for fold icons
                },
            },
        },
    },
    { -- Image Previewer for previewing images in fzf-lua
        "3rd/image.nvim",
        event = "VeryLazy",
        -- so that it doesn't build the rock https://github.com/3rd/image.nvim/issues/91#issuecomment-2453430239
        build = false,
        opts = {
            processor = "magick_cli",
            integrations = {
                markdown = { enabled = false },
            },
        },
    },
}

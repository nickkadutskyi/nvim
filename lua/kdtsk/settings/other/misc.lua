---@type LazySpec
return {
    { -- Snacks.nvim version of bigfile
        -- "folke/snacks.nvim",
        "nickkadutskyi/snacks.nvim",
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
            image = {
                enabled = true,
                formats = {
                    "png",
                    "jpg",
                    "jpeg",
                    "gif",
                    "bmp",
                    "webp",
                    "tiff",
                    "heic",
                    "avif",
                    "mp4",
                    "mov",
                    "avi",
                    "mkv",
                    "webm",
                    "pdf",
                    "svg",
                },
            },
        },
    },
}

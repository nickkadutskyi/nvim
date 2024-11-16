return {
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        opts = {
            indent = { char = "▏" },
            scope = {
                -- disables underline
                show_start = false,
                show_end = false,
            },
        },
    },
    {
        -- Detect tabstop and shiftwidth automatically
        "tpope/vim-sleuth",
    },
}

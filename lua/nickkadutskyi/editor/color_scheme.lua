return {
    {
        -- My new color scheme inspired by IntelliJ
        "nickkadutskyi/jb.nvim",
        lazy = false,
        priority = 1000,
        opts = {},
        dev = true,
        config = function()
            vim.cmd("colorscheme jb")
        end,
    },
}

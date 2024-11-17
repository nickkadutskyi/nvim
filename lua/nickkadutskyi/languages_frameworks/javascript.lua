return {
    {
        -- Better highlighting
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, {
                "javascript",
                "jsdoc",
            })
        end,
    },
    {
        -- Formatting
        "stevearc/conform.nvim",
        opts = {
            formatters_by_ft = {
                javascript = { "prettierd", "prettier" },
            },
        },
    },
}

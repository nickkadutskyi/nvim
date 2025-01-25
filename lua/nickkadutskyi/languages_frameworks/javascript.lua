---@type LazySpec
return {
    {
        -- Better highlighting
        "nvim-treesitter",
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, {
                "javascript",
                "jsdoc",
            })
        end,
    },
    { "nvim-lspconfig", opts = { servers = {} } },
    {
        -- Formatting
        "conform.nvim",
        opts = {
            formatters_by_ft = {
                javascript = { "prettierd", "prettier" },
            },
        },
    },
}

return {
    "stevearc/conform.nvim",
    opts = {
        formatters_by_ft = {
            lua = { "stylua" },
            javascript = { "prettierd", "prettier" },
            css = { "prettierd", "prettier" },
            php = { "php_cs_fixer" },
        },
        default_format_opts = {
            lsp_format = "fallback",
            stop_after_first = true,
        },
    },
}

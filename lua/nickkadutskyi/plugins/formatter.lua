return {
    "stevearc/conform.nvim",
    opts = {
        formatters_by_ft = {
            lua = { "stylua" },
            javascript = { "prettierd", "prettier" },
            css = { "prettierd", "prettier" },
            php = { "php_cs_fixer" },
            nix = { "nixfmt" },
        },
        default_format_opts = {
            lsp_format = "fallback",
            stop_after_first = true,
        },
    },
    config = function(_, opts)
        local conform = require("conform")
        conform.setup(opts)
        vim.keymap.set("n", "<leader>cf", conform.format, { noremap = true })
    end,
}

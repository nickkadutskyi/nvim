local spec = require("ide.spec.builder")

spec.add({ "nvim-treesitter", opts = { ensure_installed = { "css", "scss" } } })
spec.add({
    "conform.nvim",
    opts = {
        formatters_by_ft = {
            css = {
                { "_", nil, nil, true, { async = true, timeout_ms = 1500 } },
                {
                    "prettierd",
                    { ".prettierrc", ".prettierrc.json", ".prettierrc.js", ".prettierrc.yaml", ".prettierrc.yml" },
                },
                { "prettier" },
            },
            scss = {
                { "_", nil, nil, true, { async = true, timeout_ms = 1500 } },
                {
                    "prettierd",
                    { ".prettierrc", ".prettierrc.json", ".prettierrc.js", ".prettierrc.yaml", ".prettierrc.yml" },
                },
                { "prettier" },
            },
        },
    },
})

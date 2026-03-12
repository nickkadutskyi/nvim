local spec = require("ide.spec.builder")

spec.add({ "nvim-treesitter", opts = { ensure_installed = { "typescript", "tsx" } } })

spec.add({
    "nvim-lint",
    ---@type ide.Opts.Lint
    opts = {
        linters_by_ft = {
            typescript = {
                { "eslint_d", { "eslint.config.ts", "eslint.config.mts", "eslint.config.cts" } },
                { "eslint", { "eslint.config.js", "eslint.config.mjs", "eslint.config.cjs" } },
            },
        },
    },
})
spec.add({
    "conform.nvim",
    ---@type ide.Opts.Conform
    opts = {
        formatters_by_ft = {
            typescript = {
                { "_", nil, nil, true, { async = true, timeout_ms = 1500 } },
                {
                    "prettierd",
                    { ".prettierrc", ".prettierrc.json", ".prettierrc.js", ".prettierrc.yaml", ".prettierrc.yml" },
                },
                { "prettier" },
                { "eslint_d", { "eslint.config.ts", "eslint.config.mts", "eslint.config.cts" } },
                { "eslint", { "eslint.config.js", "eslint.config.mjs", "eslint.config.cjs" } },
            },
            javascriptreact = {
                { "_", nil, nil, true, { async = true, timeout_ms = 1500 } },
                {
                    "prettierd",
                    { ".prettierrc", ".prettierrc.json", ".prettierrc.js", ".prettierrc.yaml", ".prettierrc.yml" },
                },
                { "prettier" },
                { "eslint_d", { "eslint.config.ts", "eslint.config.mts", "eslint.config.cts" } },
                { "eslint", { "eslint.config.js", "eslint.config.mjs", "eslint.config.cjs" } },
            },
            typescriptreact = {
                { "_", nil, nil, true, { async = true, timeout_ms = 1500 } },
                {
                    "prettierd",
                    { ".prettierrc", ".prettierrc.json", ".prettierrc.js", ".prettierrc.yaml", ".prettierrc.yml" },
                },
                { "prettier" },
                { "eslint_d", { "eslint.config.ts", "eslint.config.mts", "eslint.config.cts" } },
                { "eslint", { "eslint.config.js", "eslint.config.mjs", "eslint.config.cjs" } },
            },
        },
        conform_opts = {
            formtters = {
                eslint_d = { nix_pkg = "eslint_d" },
                prettier = { nix_pkg = "prettier" },
                prettierd = { nix_pkg = "prettierd" },
            },
        },
    },
})

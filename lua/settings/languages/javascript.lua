local spec = require("ide.spec.builder")

spec.add({ "nvim-treesitter", opts = { ensure_installed = { "javascript", "jsdoc", "jsx" } } })
spec.add({
    "mfussenegger/nvim-lint",
    ---@type ide.Opts.Lint
    opts = { linters_by_ft = { javascript = { { "eslint_d", nil, nil, true } } } },
})

local prettier_config_files = {
    ".prettierrc",
    ".prettierrc.json",
    ".prettierrc.yaml",
    ".prettierrc.yml",
    ".prettierrc.js",
    "prettier.config.js",
    ".prettier.mjs",
    "prettier.config.mjs",
    ".prettier.cjs",
    "prettier.config.cjs",
    ".prettierrc.toml",
}

local eslint_config_files = {
    "eslint.config.js",
    "eslint.config.mjs",
    "eslint.config.cjs",
}

spec.add({
    "conform.nvim",
    ---@type ide.Opts.Conform
    opts = {
        formatters_by_ft = {
            javascript = {
                { "_", nil, nil, true, { async = true, timeout_ms = 1500 } },
                { "prettierd", prettier_config_files },
                { "eslint_d", eslint_config_files },
            },
            javascriptreact = {
                { "_", nil, nil, true, { async = true, timeout_ms = 1500 } },
                { "prettierd", prettier_config_files },
                { "eslint_d", eslint_config_files },
            },
        },
    },
})
spec.add({
    "nvim-lspconfig",
    opts = { ---@type ide.Opts.Lsp
        clients = {
            ["eslint"] = {
                enabled = { eslint_config_files },
                nix_pkg = "vscode-langservers-extracted",
            },
            ["vtsls"] = {
                enabled = { { "jsconfig.json" } },
            },
        },
    },
})

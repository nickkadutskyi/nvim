local spec = require("ide.spec.builder")

spec.add({ "nvim-treesitter", opts = { ensure_installed = { "yaml" } } })

spec.add({
    "nvim-lint",
    ---@type ide.Opts.Lint
    opts = {
        linters_by_ft = {
            yaml = { { "yamllint", { ".yamllint", ".yamllint.yaml", ".yamllint.yml" } } },
        },
    },
})
spec.add({
    "conform.nvim",
    ---@type ide.Opts.Conform
    opts = {
        formatters_by_ft = {
            yaml = { { "yamlfmt", { ".yamlfmt" }, nil, true, { timeout_ms = 1500 }  } },
        },
        conform_opts = {
            formatters = {
                yamlfmt = {
                    options = {
                        nix_pkg = "yamlfmt",
                    },
                },
            },
        },
    },
})
spec.add({
    "nvim-lspconfig",
    opts = { ---@type ide.Opts.Lsp
        clients = {
            yamlls = {
                enabled = { nil, nil, false },
            },
        },
    },
})

local spec = require("ide.spec.builder")

spec.add({ "nvim-treesitter", opts = { ensure_installed = { "python" } } })

spec.add({
    "nvim-lint",
    ---@type ide.Opts.Lint
    opts = {
        linters_by_ft = {
            python = {
                { "ruff", { "ruff.toml", ".ruff.toml" } },
                { "flake8", { ".flake8" } },
                { "pylint" },
            },
        },
        linters = {
            flake8 = { nix_pkg = "python314Packages.flake8" },
        },
    },
})
spec.add({
    "conform.nvim",
    ---@type ide.Opts.Conform
    opts = {
        formatters_by_ft = {
            python = {
                { "isort", { ".isort.cfg" } },
                { "black" },
            },
        },
    },
})
spec.add({
    "nvim-lspconfig",
    opts = { ---@type ide.Opts.Lsp
        clients = {
            pylsp = {
                nix_pkg = "python313Packages.python-lsp-server", -- pylsp
                enabled = { nil, nil, false },
            },
            pyright = {
                nix_pkg = "pyright", -- pyright-langserver
                enabled = { { "pyrightconfig.json" } },
            },
        },
    },
})

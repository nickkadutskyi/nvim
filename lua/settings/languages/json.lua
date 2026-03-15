local spec = require("ide.spec.builder")

spec.add({ "nvim-treesitter", opts = { ensure_installed = { "json" } } })
spec.add({
    "conform.nvim",
    ---@type ide.Opts.Conform
    opts = { formatters_by_ft = { json = { { "_", nil, nil, true, { lsp_format = "first" } } } } },
})
spec.add({
    "nvim-lspconfig",
    opts = { ---@type ide.Opts.Lsp
        clients = {
            ["jsonls"] = {
                nix_pkg = "vscode-langservers-extracted",
            },
        },
    },
})

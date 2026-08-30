local spec = require("ide.spec.builder")

spec.add({ "nvim-treesitter", opts = { ensure_installed = { "json" } } })
spec.add({
    "conform.nvim",
    ---@type ide.Opts.Conform
    opts = { formatters_by_ft = { json = { { "_", nil, nil, true, { lsp_format = "first" } } } } },
})
spec.add({
    "nvim-lspconfig",
    ---@type ide.Opts.Lsp
    opts = {
        clients = {
            ["jsonls"] = {
                nix_pkg = "vscode-langservers-extracted",
            },
        },
    },
})

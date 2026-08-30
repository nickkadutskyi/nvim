local spec = require("ide.spec.builder")

spec.add({ "nvim-treesitter", opts = { ensure_installed = { "bash" } } })
spec.add({
    "conform.nvim",
    ---@type ide.Opts.Conform
    opts = { formatters_by_ft = { sh = { { "shfmt", nil, nil, true } } } },
})
spec.add({
    "nvim-lspconfig",
    ---@type ide.Opts.Lsp
    opts = {
        clients = {
            ["bashls"] = {
                filetypes = { "sh", "zsh" },
            },
        },
    },
})

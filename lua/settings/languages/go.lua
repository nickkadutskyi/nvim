local spec = require("ide.spec.builder")

spec.add({
    "nvim-treesitter",
    ---@type ide.Opts.Treesitter
    opts = {
        ensure_installed = { "go", "gotmpl" },
        syntax_map = { ["gotexttmpl"] = "gotmpl", ["gohtmltmpl"] = "gotmpl" },
    },
})
spec.add({
    "nvim-lspconfig",
    ---@type ide.Opts.Lsp
    opts = {
        clients = {
            ["gopls"] = { enabled = false },
        },
    },
})

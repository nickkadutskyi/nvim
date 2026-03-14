local spec = require("ide.spec.builder")

spec.add({
    "nvim-treesitter",
    opts = { ---@type ide.Opts.Treesitter
        ensure_installed = { "go", "gotmpl" },
        syntax_map = { ["gotexttmpl"] = "gotmpl", ["gohtmltmpl"] = "gotmpl" },
    },
})
spec.add({
    "nvim-lspconfig",
    opts = { ---@type ide.Opts.Lsp
        clients = {
            ["gopls"] = { enabled = false },
        },
    },
})

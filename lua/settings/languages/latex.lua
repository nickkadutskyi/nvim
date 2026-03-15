local spec = require("ide.spec.builder")

spec.add({ "nvim-treesitter", opts = { ensure_installed = { "latex", "bibtex" } } })
spec.add({
    "nvim-lspconfig",
    opts = { ---@type ide.Opts.Lsp
        clients = {
            ["texlab"] = { nix_pkg = "texlab" },
            ["ltex_plus"] = { nix_pkg = "ltex-ls-plus" },
        },
    },
})

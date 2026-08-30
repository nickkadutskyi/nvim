local spec = require("ide.spec.builder")

spec.add({ "nvim-treesitter", opts = { ensure_installed = { "scala" } } })
spec.add({
    "nvim-lspconfig",
    ---@type ide.Opts.Lsp
    opts = {
        clients = {
            ["metals"] = {
                nix_pkg = "metals",
            },
        },
    },
})

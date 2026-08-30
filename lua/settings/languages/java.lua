local spec = require("ide.spec.builder")

spec.add({ "nvim-treesitter", opts = { ensure_installed = { "java", "javadoc" } } })
spec.add({
    "nvim-lspconfig",
    ---@type ide.Opts.Lsp
    opts = {
        clients = {
            java_language_server = {
                cmd = { "java-language-server" },
                nix_pkg = "java-language-server",
            },
            ["jdtls"] = {
                nix_pkg = "jdt-language-server",
            },
        },
    },
})

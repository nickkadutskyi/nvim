---@type LazySpec
return {
    { -- Language Servers
        "nvim-lspconfig",
        opts = {
            ---@type table<string,vim.lsp.ConfigLocal>
            servers = {
                java_language_server = {
                    cmd = { "java-language-server" },
                    nix_pkg = "java-language-server",
                },
                ["jdtls"] = {
                    nix_pkg = "jdt-language-server",
                },
            },
        },
    },
}

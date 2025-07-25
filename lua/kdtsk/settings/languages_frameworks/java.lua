---@type LazySpec
return {
    { -- Color Scheme
        "nvim-treesitter",
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, {
                "java",
                "javadoc",
            })
        end,
    },
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

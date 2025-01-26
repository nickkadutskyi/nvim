---@type LazySpec
return {
    { -- Color Scheme
        "nvim-treesitter",
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, {
                "java",
            })
        end,
    },
    { -- Language Servers
        "nvim-lspconfig",
        opts = {
            servers = {
                java_language_server = {
                    cmd = { "java-language-server" },
                },
            },
        },
    },
}

---@type LazySpec
return {
    { -- Code Style
        "stevearc/conform.nvim",
        opts = {
            formatters_by_ft = {
                toml = { "taplo" },
            },
        },
    },
    { -- Language Servers
        "nvim-lspconfig",
        opts = {
            servers = {
                -- Works as a linter
                taplo = {},
            },
        },
    },
}

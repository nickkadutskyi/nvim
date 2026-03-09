---@type LazySpec
return {
    { -- Code Style
        "conform.nvim",
        opts = {
            formatters_by_ft = {
                toml = { "taplo" },
            },
        },
    },
    { -- Language Servers
        "nvim-lspconfig",
        opts = {
            ---@type table<string,vim.lsp.ConfigLocal>
            servers = {
                -- Works as a linter
                taplo = {},
            },
        },
    },
}

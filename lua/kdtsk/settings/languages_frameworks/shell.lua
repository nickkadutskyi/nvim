---@type LazySpec
return {
    { -- Language Servers
        "nvim-lspconfig",
        opts = {
            ---@type table<string,vim.lsp.ConfigLocal>
            servers = {
                ["bashls"] = {
                    filetypes = { "sh", "zsh" },
                },
            },
        },
    },
    { -- Code Style
        "conform.nvim",
        opts = {
            formatters_by_ft = {
                sh = {
                    "shfmt",
                },
            },
        },
    },
}

---@type LazySpec
return {
    {
        "nvim-lspconfig",
        opts = {
            ---@type table<string,vim.lsp.ConfigLocal>
            servers = {
                ["jsonls"] = {},
            },
        },
    },
    {
        "conform.nvim", -- Code Style
        opts = {
            formatters_by_ft = {
                json = {
                    lsp_format = "first",
                },
            },
        },
    },
}

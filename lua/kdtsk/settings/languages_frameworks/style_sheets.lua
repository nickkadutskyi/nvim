---@type LazySpec
return {
    {
        "nvim-lspconfig",
        opts = {
            ---@type table<string,vim.lsp.ConfigLocal>
            servers = {
                stylelint_lsp = {},
                cssls = {},
            },
        },
    },
}

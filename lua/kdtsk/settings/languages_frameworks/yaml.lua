---@type LazySpec
return {
    {
        "nvim-lspconfig", -- Language Servers
        opts = {
            ---@type table<string,vim.lsp.ConfigLocal>
            servers = {
                yamlls = {
                    enabled = Utils.tools.is_component_enabled("yaml", "yamlls", Utils.tools.purpose.LSP),
                },
            },
        },
    },
}

---@type LazySpec
return {
    {
        "nvim-lspconfig", -- Language Servers
        opts = function(_, opts)
            local servers = {
                ["laravel_ls"] = {
                    enabled = Utils.tools.is_component_enabled(
                        "laravel",
                        "laravel_ls",
                        Utils.tools.purpose.LSP,
                        { "artisan" }
                    ),
                },
            }

            return vim.tbl_deep_extend("force", opts, {
                ---@type table<string,vim.lsp.ConfigLocal>
                servers = servers,
            })
        end,
    },
}

---@type LazySpec
return {
    {
        "nvim-lspconfig", -- Language Servers
        opts = function(_, opts)
            return vim.tbl_deep_extend("force", opts, {
                ---@type table<string,vim.lsp.ConfigLocal>
                servers = {
                    ["texlab"] = { nix_pkg = "texlab" },
                    ["ltex_plus"] = { nix_pkg = "ltex-ls-plus" },
                },
            })
        end,
    },
}

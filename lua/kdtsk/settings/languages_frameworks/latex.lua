---@type LazySpec
return {
    {
        "nvim-treesitter", -- Color Scheme
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, {
                "latex",
                "bibtex",
            })
        end,
    },
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

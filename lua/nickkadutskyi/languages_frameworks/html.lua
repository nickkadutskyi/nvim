---@type LazySpec
return {
    { -- Color Scheme
        "nvim-treesitter",
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, {
                "html",
            })
        end,
    },
    { -- Language Servers
        "nvim-lspconfig",
        opts = {
            servers = {
                ["html"] = {},
            },
        },
    },
}

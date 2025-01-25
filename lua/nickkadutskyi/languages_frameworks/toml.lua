---@type LazySpec
return {
    { -- Color Scheme
        "nvim-treesitter",
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, {
                "toml",
            })
        end,
    },
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
            servers = {
                -- Works as a linter
                taplo = {},
            },
        },
    },
}

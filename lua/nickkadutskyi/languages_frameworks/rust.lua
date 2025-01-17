---@type LazySpec
return {
    { -- Color Scheme
        "nvim-treesitter",
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, {
                "rust",
            })
        end,
    },
    { -- Code Style
        "conform.nvim",
        opts = {
            formatters_by_ft = {
                rust = { "rustfmt", lsp_format = "fallback" },
            },
        },
    },
    { -- Language Servers
        "nvim-lspconfig",
        opts = {
            servers = {
                rust_analyzer = {},
            },
        },
    },
    { -- Quality Tools
        "nvim-lint",
        opts = {
            linters_by_ft = {
                rust = { "clippy" },
            },
        },
    },
}

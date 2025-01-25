---@type LazySpec
return {
    { -- Color Scheme
        "nvim-treesitter",
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, {
                "ruby",
            })
        end,
    },
    { -- Code Style
        "conform.nvim",
        opts = {
            formatters_by_ft = {
                ruby = { "standardrb", lsp_format = "fallback" },
            },
        },
    },
    { -- Language Servers
        "nvim-lspconfig",
        opts = {
            servers = {
                ruby_lsp = {},
                standardrb = {}, -- as linter
                rubocop = {}, -- as linter
                solargraph = {},
            },
        },
    },
    { -- Quality Tools (moved to LSP)
        -- "nvim-lint",
        -- opts = {
        --     linters_by_ft = {
        --         ruby = { "RuboCop", "StandardRB" },
        --     },
        -- },
    },
}

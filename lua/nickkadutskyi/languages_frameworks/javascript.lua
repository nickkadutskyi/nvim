---@type LazySpec
return {
    {
        -- Better highlighting
        "nvim-treesitter",
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, {
                "javascript",
                "jsdoc",
            })
        end,
    },
    {
        "nvim-lspconfig",
        opts = {
            servers = {
                ["ts_ls"] = {},
            },
        },
    },
    {
        -- Formatting
        "conform.nvim",
        opts = {
            formatters_by_ft = {
                javascript = { "prettierd", "prettier" },
            },
        },
    },
    { -- Code Style
        "conform.nvim",
        opts = function(_, opts)
            return vim.tbl_deep_extend("force", opts, {
                formatters_by_ft = {
                    javascript = {
                        "eslint_d",
                    },
                },
            })
        end,
    },
    { -- Quality Tools
        "nvim-lint",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = { "stevearc/conform.nvim" },
        opts = function(_, opts) -- Configure in opts to run all configs for all languages
            return vim.tbl_deep_extend("force", opts, {
                linters_by_ft = {
                    javascript = {
                        "eslint_d",
                    },
                },
            })
        end,
    },
}

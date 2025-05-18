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
            ---@type table<string,vim.lsp.ConfigLocal>
            servers = {
                ["ts_ls"] = {},
            },
        },
    },
    { -- Code Style
        "conform.nvim",
        opts = function(_, opts)
            return vim.tbl_deep_extend("force", opts, {
                formatters_by_ft = {
                    javascript = {
                        "prettierd",
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

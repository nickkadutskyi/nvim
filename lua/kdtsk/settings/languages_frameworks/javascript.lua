---@type LazySpec
return {
    {
        -- Better highlighting
        "nvim-treesitter",
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, {
                "javascript",
                "jsdoc",
                "jsx",
            })
        end,
    },
    {
        "nvim-lspconfig",
        opts = function(_, opts)
            local servers = {}

            -- Typescript & Javascript Language Server
            servers = Utils.tools.extend_if_enabled(servers, {
                ["ts_ls"] = Utils.js.servers.ts_ls,
            }, {
                "javascript",
                "ts_ls",
                Utils.tools.purpose.LSP,
                { "jsconfig.json" },
            })
            -- Eslint
            servers = Utils.tools.extend_if_enabled(servers, {
                ["eslint"] = Utils.js.servers.eslint,
            }, {
                "javascript",
                "eslint",
                Utils.tools.purpose.LSP,
                { "eslint.config.js", "eslint.config.mjs", "eslint.config.cjs"},
            })

            return vim.tbl_deep_extend("force", opts, {
                ---@type table<string,vim.lsp.ConfigLocal>
                servers = servers,
            })
        end,
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

---@type LazySpec
return {
    {
        -- Better highlighting
        "nvim-treesitter",
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, {
                "typescript",
                "tsx",
            })
        end,
    },
    {
        "nvim-lspconfig",
        opts = function(_, opts)
            ---@type table<string,vim.lsp.ConfigLocal>
            local servers = {}

            -- Eslint
            servers = Utils.tools.extend_if_enabled(servers, {
                ["eslint"] = Utils.js.servers.eslint,
            }, {
                "typescript",
                "eslint",
                Utils.tools.purpose.LSP,
                { "eslint.config.ts", "eslint.config.mts", "eslint.config.cts" },
            })

            -- NOTE: Use either ts_ls or vtsls, not both, since they will conflict with each other. vtsls is preferred since
            -- it provides better support for Vue projects, but ts_ls is more stable and has better support for pure
            -- Typescript projects.

            -- Typescript & Javascript Language Server
            servers = Utils.tools.extend_if_enabled(servers, {
                ["ts_ls"] = Utils.js.servers.ts_ls,
            }, {
                "typescript",
                "ts_ls",
                Utils.tools.purpose.LSP,
                { "tsconfig.json" },
            })

            -- Vtsls
            servers = Utils.tools.extend_if_enabled(servers, {
                ["vtsls"] = Utils.js.servers.vtsls,
            }, {
                "typescript",
                "vtsls",
                Utils.tools.purpose.LSP,
            })
            servers = Utils.tools.extend_if_enabled(servers, {
                ["vtsls"] = Utils.js.servers.vtsls,
            }, {
                "vue",
                "vue_ls",
                Utils.tools.purpose.LSP,
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
            local fmt_conf = {
                async = true,
                timeout_ms = 1500,
            }

            -- Prettierd
            fmt_conf = Utils.tools.extend_if_enabled(fmt_conf, { "prettierd" }, {
                "typescript",
                "prettierd",
                Utils.tools.purpose.STYLE,
                { ".prettierrc", ".prettierrc.json", ".prettierrc.js", ".prettierrc.yaml", ".prettierrc.yml" },
            })
            -- Prettier
            fmt_conf = Utils.tools.extend_if_enabled(fmt_conf, { "prettier" }, {
                "typescript",
                "prettier",
                Utils.tools.purpose.STYLE,
            })
            -- Eslint_d
            fmt_conf = Utils.tools.extend_if_enabled(fmt_conf, { "eslint_d" }, {
                "typescript",
                "eslint_d",
                Utils.tools.purpose.STYLE,
                { ".eslintrc", ".eslintrc.json", ".eslintrc.js", "eslint.config.js", "eslint.config.ts" },
            })
            -- Eslint as formatter
            fmt_conf = Utils.tools.extend_if_enabled(fmt_conf, { lsp_format = "first" }, {
                "typescript",
                "eslint",
                Utils.tools.purpose.STYLE,
            })

            return vim.tbl_deep_extend("force", opts, {
                formatters_by_ft = {
                    typescript = fmt_conf,
                    javascriptreact = fmt_conf,
                    typescriptreact = fmt_conf,
                },
                formtters = {
                    eslint_d = { nix_pkg = "eslint_d" },
                    prettier = { nix_pkg = "prettier" },
                    prettierd = { nix_pkg = "prettierd" },
                },
            })
        end,
    },
    {
        "nvim-lint", -- Quality Tools
        event = { "BufReadPre", "BufNewFile" },
        opts = function(_, opts) -- Configure in opts to run all configs for all languages
            local lint_conf = {}

            -- Eslint_d
            lint_conf = Utils.tools.extend_if_enabled(lint_conf, { "eslint_d" }, {
                "typescript",
                "eslint_d",
                Utils.tools.purpose.INSPECTION,
                { ".eslintrc", ".eslintrc.json", ".eslintrc.js", "eslint.config.js", "eslint.config.ts" },
            })
            -- Eslint
            lint_conf = Utils.tools.extend_if_enabled(lint_conf, { "eslint" }, {
                "typescript",
                "eslint",
                Utils.tools.purpose.INSPECTION,
                { ".eslintrc", ".eslintrc.json", ".eslintrc.js", "eslint.config.js", "eslint.config.ts" },
            })

            return vim.tbl_deep_extend("force", opts, {
                ---@type table<string, string[]>
                linters_by_ft = { typescript = lint_conf },
                ---@type table<string, lint.LinterLocal>
                linters = {},
            })
        end,
    },
}

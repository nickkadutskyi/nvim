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
            return vim.tbl_deep_extend("force", opts, {
                ---@type table<string,vim.lsp.ConfigLocal>
                servers = {
                    ["eslint"] = {
                        enabled = Utils.tools.is_component_enabled("typescript", "eslint", Utils.tools.purpose.LSP, {
                            ".eslintrc",
                            ".eslintrc.json",
                            ".eslintrc.js",
                            "eslint.config.js",
                            "eslint.config.ts",
                        }),
                        nix_pkg = "vscode-langservers-extracted",
                    },
                    ["ts_ls"] = {
                        enabled = Utils.tools.is_component_enabled("typescript", "ts_ls", Utils.tools.purpose.LSP, {
                            "tsconfig.json",
                            "jsconfig.json",
                        }),
                        nix_pkg = "typescript-language-server",
                        init_options = {
                            hostInfo = "neovim",
                            preferences = {
                                includeCompletionsForModuleExports = true,
                                includeCompletionsForImportStatements = true,
                                importModuleSpecifierPreference = "relative",
                            },
                        },
                        filetypes = vim.lsp.config["ts_ls"].filetypes or {},
                    },
                    ["vtsls"] = {
                        enabled = Utils.tools.is_component_enabled("typescript", "vtsls", Utils.tools.purpose.LSP, {
                            "tsconfig.json",
                            "jsconfig.json",
                        })
                            -- Enable if vue_ls is enabled since it requires vtsls
                            or Utils.tools.is_component_enabled("vue", "vue_ls", Utils.tools.purpose.LSP),
                        nix_pkg = "vtsls",
                        filetypes = vim.lsp.config["vtsls"].filetypes or {},
                        settings = {
                            complete_function_calls = true,
                            vtsls = {
                                enableMoveToFileCodeAction = true,
                                autoUseWorkspaceTsdk = true,
                                experimental = {
                                    maxInlayHintLength = 30,
                                    completion = {
                                        enableServerSideFuzzyMatch = true,
                                    },
                                },
                                tsserver = {
                                    -- Add plugins in corresponding files
                                    globalPlugins = {},
                                },
                            },
                            javascript = {
                                updateImportsOnFileMove = "always",
                            },
                            typescript = {
                                updateImportsOnFileMove = { enabled = "always" },
                                suggest = {
                                    completeFunctionCalls = true,
                                },
                                inlayHints = {
                                    enumMemberValues = { enabled = true },
                                    functionLikeReturnTypes = { enabled = true },
                                    parameterNames = { enabled = "literals" },
                                    parameterTypes = { enabled = true },
                                    propertyDeclarationTypes = { enabled = true },
                                    variableTypes = { enabled = false },
                                },
                                preferences = {
                                    includeCompletionsForModuleExports = true,
                                    includeCompletionsForImportStatements = true,
                                    importModuleSpecifier = "non-relative",
                                },
                            },
                        },
                    },
                },
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
                formatters_by_ft = { typescript = fmt_conf },
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

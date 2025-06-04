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
        opts = {
            ---@type table<string,vim.lsp.ConfigLocal>
            servers = {
                ["ts_ls"] = {
                    enabled = false,
                    init_options = {
                        plugins = {
                            {
                                name = "@vue/typescript-plugin",
                                -- location = "/usr/local/lib/node_modules/@vue/typescript-plugin",
                                location = "",
                                languages = { "javascript", "typescript", "vue" },
                            },
                        },
                        hostInfo = "neovim",
                        preferences = {
                            includeCompletionsForModuleExports = true,
                            includeCompletionsForImportStatements = true,
                            importModuleSpecifierPreference = "relative",
                        },
                    },
                    filetypes = {
                        "typescript",
                        "javascript",
                        "javascriptreact",
                        "typescriptreact",
                        "vue",
                        "javascript.jsx",
                        "typescript.tsx",
                    },
                },
                ["vtsls"] = {
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
                    filetypes = {
                        "typescript",
                        "javascript",
                        "javascriptreact",
                        "typescriptreact",
                        "vue",
                        "javascript.jsx",
                        "typescript.tsx",
                    },
                },
            },
        },
    },
    { -- Code Style
        "conform.nvim",
        opts = function(_, opts)
            return vim.tbl_deep_extend("force", opts, {
                formatters_by_ft = {
                    typescript = {
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
                    typescript = {
                        "eslint_d",
                    },
                },
            })
        end,
    },
}

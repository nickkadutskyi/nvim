local spec = require("ide.spec.builder")

spec.add({ "nvim-treesitter", opts = { ensure_installed = { "typescript", "tsx" } } })

spec.add({
    "nvim-lint",
    ---@type ide.Opts.Lint
    opts = {
        linters_by_ft = {
            typescript = {
                { "eslint_d", { "eslint.config.ts", "eslint.config.mts", "eslint.config.cts" } },
                { "eslint", { "eslint.config.js", "eslint.config.mjs", "eslint.config.cjs" } },
            },
        },
    },
})

local prettier_config_files = {
    ".prettierrc",
    ".prettierrc.json",
    ".prettierrc.yaml",
    ".prettierrc.yml",
    ".prettierrc.ts",
    "prettier.config.ts",
    ".prettier.mts",
    "prettier.config.mts",
    ".prettier.cts",
    "prettier.config.cts",
    ".prettierrc.toml",
}

local eslint_config_files = {
    "eslint.config.ts",
    "eslint.config.mts",
    "eslint.config.cts",
}

spec.add({
    "conform.nvim",
    ---@type ide.Opts.Conform
    opts = {
        formatters_by_ft = {
            typescript = {
                { "_", nil, nil, true, { async = true, timeout_ms = 1500 } },
                { "prettierd", prettier_config_files },
                { "eslint_d", eslint_config_files },
            },
            typescriptreact = {
                { "_", nil, nil, true, { async = true, timeout_ms = 1500 } },
                { "prettierd", prettier_config_files },
                { "eslint_d", eslint_config_files },
            },
        },
        conform_opts = {
            formtters = {
                eslint_d = { nix_pkg = "eslint_d" },
                prettier = { nix_pkg = "prettier" },
                prettierd = { nix_pkg = "prettierd" },
            },
        },
    },
})
spec.add({
    "nvim-lspconfig",
    opts = { ---@type ide.Opts.Lsp
        clients = {
            ["eslint"] = {
                enabled = { eslint_config_files },
                nix_pkg = "vscode-langservers-extracted",
            },
            ["vtsls"] = {
                enabled = { { "tsconfig.json" } },
                nix_pkg = "vtsls",
                -- Repeating it here because we might add more types here via spec opts_extend
                filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact" },
                settings = {
                    complete_function_calls = true,
                    vtsls = {
                        enableMoveToFileCodeAction = true,
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
    },
})

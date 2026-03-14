local spec = require("ide.spec.builder")

spec.add({ "nvim-treesitter", opts = { ensure_installed = { "javascript", "jsdoc", "jsx" } } })
spec.add({
    "mfussenegger/nvim-lint",
    ---@type ide.Opts.Lint
    opts = { linters_by_ft = { javascript = { { "eslint_d", nil, nil, true } } } },
})
spec.add({
    "conform.nvim",
    ---@type ide.Opts.Conform
    opts = { formatters_by_ft = { javascript = { { "prettierd", nil, nil, true } } } },
})
spec.add({
    "nvim-lspconfig",
    opts = { ---@type ide.Opts.Lsp
        clients = {
            ["ts_ls"] = {
                enabled = {
                    nil,
                    function()
                        -- TODO: enable only if vue_Ls or vtsls are not enabled
                        --       and either tsconfig.json or jsoncfig.json are present
                        return false
                    end,
                },
                nix_pkg = "typescript-language-server",
                init_options = {
                    hostInfo = "neovim",
                    preferences = {
                        includeCompletionsForModuleExports = true,
                        includeCompletionsForImportStatements = true,
                        importModuleSpecifierPreference = "relative",
                    },
                    -- Add plugins in corresponding files
                    plugins = {},
                },
                -- filetypes = vim.lsp.config["ts_ls"].filetypes or {},
            },
        },
    },
})

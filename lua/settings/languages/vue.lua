local spec = require("ide.spec.builder")

spec.add({ "nvim-treesitter", opts = { ensure_installed = { "vue" } } })
spec.add({
    "conform.nvim",
    ---@type ide.Opts.Conform
    opts = {
        formatters_by_ft = {
            vue = {
                { "_", nil, nil, true, { async = true, timeout_ms = 1500 } },
                {
                    "prettierd",
                    { ".prettierrc", ".prettierrc.json", ".prettierrc.js", ".prettierrc.yaml", ".prettierrc.yml" },
                },
                { "prettier" },
                { "eslint_d", { "eslint.config.ts", "eslint.config.mts", "eslint.config.cts" } },
                { "eslint", { "eslint.config.js", "eslint.config.mjs", "eslint.config.cjs" } },
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
            ["vtsls"] = {
                on_attach = function(client)
                    -- NOTE: see https://github.com/vuejs/language-tools/wiki/Neovim#custom-component-highlight
                    -- Since 3.0.2, semantic tokens are handled
                    -- on the vue_ls side rather than tsserver,
                    -- and the token name has changed, to adopt
                    -- this change you have to:
                    if vim.bo.filetype == "vue" then
                        client.server_capabilities.semanticTokensProvider.full = false
                    else
                        client.server_capabilities.semanticTokensProvider.full = true
                    end
                end,
                filetypes = { "vue" },
            },
        },
    },
})

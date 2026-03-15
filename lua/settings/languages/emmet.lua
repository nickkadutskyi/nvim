local spec = require("ide.spec.builder")

spec.add({
    "nvim-lspconfig",
    opts = { ---@type ide.Opts.Lsp
        clients = {
            ["emmet_language_server"] = {
                nix_pkg = "emmet-language-server",
                enabled = true,
                filetypes = {
                    "astro",
                    "css",
                    "eruby",
                    "html",
                    "htmlangular",
                    "htmldjango",
                    "javascriptreact",
                    "less",
                    "sass",
                    "scss",
                    "svelte",
                    "typescriptreact",
                    "vue",
                    "php",
                    "typescript",
                    "javascript",
                    "blade",
                    "twig",
                },
            },
        },
    },
})

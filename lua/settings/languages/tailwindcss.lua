local spec = require("ide.spec.builder")

spec.add({
    "nvim-lspconfig",
    opts = { ---@type ide.Opts.Lsp
        clients = {
            ["tailwindcss"] = {
                enalbed = {
                    {
                        "tailwind.config.js",
                        "tailwind.config.cjs",
                        "tailwind.config.ts",
                        "postcss.config.js",
                        "postcss.config.ts",
                    },
                },
                nix_pkg = "tailwindcss-language-server",
            },
        },
    },
})

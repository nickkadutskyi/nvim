local spec = require("ide.spec.builder")
local utils = require("ide.utils")

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
                bin = function()
                    return utils.tool.find_js_executable("tailwindcss-language-server")
                end,
            },
        },
    },
})

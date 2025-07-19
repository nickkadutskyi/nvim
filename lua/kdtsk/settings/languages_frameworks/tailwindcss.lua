---@type LazySpec
return {
    {
        "nvim-lspconfig", -- Language Servers
        opts = function(_, opts)
            return vim.tbl_deep_extend("force", opts, {
                ---@type table<string,vim.lsp.ConfigLocal>
                servers = {
                    ["tailwindcss"] = {
                        enabled = Utils.tools.is_component_enabled(
                            "tailwindcss",
                            "tailwindcss",
                            Utils.tools.purpose.LSP,
                            {
                                "tailwind.config.js",
                                "tailwind.config.cjs",
                                "tailwind.config.ts",
                                "postcss.config.js",
                                "postcss.config.ts",
                            }
                        ),
                        nix_pkg = "tailwindcss-language-server",
                    },
                },
            })
        end,
    },
}

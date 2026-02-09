---@type LazySpec
return {
    { -- Color Scheme
        "nvim-treesitter",
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, {
                "blade",
            })
        end,
    },
    {
        "nvim-lspconfig", -- Language Servers
        opts = function(_, opts)
            local servers = {
                ["laravel_ls"] = {
                    enabled = Utils.tools.is_component_enabled(
                        "laravel",
                        "laravel_ls",
                        Utils.tools.purpose.LSP,
                        { "artisan" }
                    ),
                },
            }

            return vim.tbl_deep_extend("force", opts, {
                ---@type table<string,vim.lsp.ConfigLocal>
                servers = servers,
            })
        end,
    },
    {
        "conform.nvim", -- Code Style
        opts = function(_, opts)
            local fmt_conf_blade = {
                async = true,
                timeout_ms = 1500,
            }

            fmt_conf_blade = Utils.tools.extend_if_enabled(fmt_conf_blade, { "blade-formatter" }, {
                "blade",
                "blade-formatter",
                Utils.tools.purpose.STYLE,
                { ".bladeformatterrc.json", ".bladeformatterrc" },
            })
            -- Prettierd
            fmt_conf_blade = Utils.tools.extend_if_enabled(fmt_conf_blade, { "prettierd" }, {
                "blade",
                "prettierd",
                Utils.tools.purpose.STYLE,
                { ".prettierrc", ".prettierrc.json", ".prettierrc.js", ".prettierrc.yaml", ".prettierrc.yml" },
            })
            -- Prettier
            fmt_conf_blade = Utils.tools.extend_if_enabled(fmt_conf_blade, { "prettier" }, {
                "blade",
                "prettier",
                Utils.tools.purpose.STYLE,
            })

            return vim.tbl_deep_extend("force", opts, {
                formatters_by_ft = { blade = fmt_conf_blade },
                formatters = {
                    ["blade-formatter"] = { nix_pkg = "blade-formatter" },
                },
            })
        end,
    },
}

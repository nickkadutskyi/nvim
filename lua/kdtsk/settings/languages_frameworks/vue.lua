---@type LazySpec
return {
    {
        -- Better highlighting
        "nvim-treesitter",
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, {
                "vue",
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
                "vue",
                "prettierd",
                Utils.tools.purpose.STYLE,
                { ".prettierrc", ".prettierrc.json", ".prettierrc.js", ".prettierrc.yaml", ".prettierrc.yml" },
            })
            -- Prettier
            fmt_conf = Utils.tools.extend_if_enabled(fmt_conf, { "prettier" }, {
                "vue",
                "prettier",
                Utils.tools.purpose.STYLE,
            })
            -- Eslint_d
            fmt_conf = Utils.tools.extend_if_enabled(fmt_conf, { "eslint_d" }, {
                "vue",
                "eslint_d",
                Utils.tools.purpose.STYLE,
                { ".eslintrc", ".eslintrc.json", ".eslintrc.js", "eslint.config.js", "eslint.config.ts" },
            })

            return vim.tbl_deep_extend("force", opts, {
                formatters_by_ft = { vue = fmt_conf },
                formtters = {
                    eslint_d = { nix_pkg = "eslint_d" },
                    prettier = { nix_pkg = "prettier" },
                    prettierd = { nix_pkg = "prettierd" },
                },
            })
        end,
    },
    {
        "nvim-lspconfig",
        opts = function(_, opts)
            local servers = {}
            if Utils.tools.is_component_enabled("vue", "vue_ls", Utils.tools.purpose.LSP) then
                -- See https://github.com/vuejs/language-tools/wiki/Neovim for Vue language server setup
                Utils.extend(opts.servers.vtsls, "filetypes", { "vue" })
                Utils.extend(opts.servers.ts_ls, "filetypes", { "vue" })
                local vue_plugin = {
                    name = "@vue/typescript-plugin",
                    location = vim.fn.getcwd() .. "/node_modules/@vue/language-server",
                    languages = { "vue" },
                    configNamespace = "typescript",
                    enableForWorkspaceTypeScriptVersions = true,
                }

                Utils.extend(opts.servers.vtsls, "settings.vtsls.tsserver.globalPlugins", {
                    vue_plugin,
                })
                Utils.extend(opts.servers.ts_ls, "init_options.plugins", {
                    vue_plugin,
                })

                servers["vue_ls"] = {
                    enabled = true,
                    bin = Utils.js.find_executable("vue-language-server"),
                }
            end
            return vim.tbl_deep_extend("force", opts, {
                ---@type table<string,vim.lsp.ConfigLocal>
                servers = servers,
            })
        end,
    },
}

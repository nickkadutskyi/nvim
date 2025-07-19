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
                "typescript",
                "prettierd",
                Utils.tools.purpose.STYLE,
                { ".prettierrc", ".prettierrc.json", ".prettierrc.js", ".prettierrc.yaml", ".prettierrc.yml" },
            })
            -- Prettier
            fmt_conf = Utils.tools.extend_if_enabled(fmt_conf, { "prettier" }, {
                "typescript",
                "prettier",
                Utils.tools.purpose.STYLE,
            })
            -- Eslint_d
            fmt_conf = Utils.tools.extend_if_enabled(fmt_conf, { "eslint_d" }, {
                "typescript",
                "eslint_d",
                Utils.tools.purpose.STYLE,
                { ".eslintrc", ".eslintrc.json", ".eslintrc.js", "eslint.config.js", "eslint.config.ts" },
            })

            return vim.tbl_deep_extend("force", opts, {
                formatters_by_ft = { typescript = fmt_conf },
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
                Utils.extend(opts.servers.vtsls, "settings.vtsls.tsserver.globalPlugins", {
                    {
                        name = "@vue/typescript-plugin",
                        location = vim.fn.getcwd() .. "/node_modules/@vue/language-server",
                        languages = { "vue" },
                        configNamespace = "typescript",
                        enableForWorkspaceTypeScriptVersions = true,
                    },
                })

                servers["vue_ls"] = {
                    enabled = true,
                    init_options = {
                        vue = {
                            hybridMode = true,
                        },
                    },
                    on_init = function(client)
                        client.handlers["tsserver/request"] = function(_, result, context)
                            local clients = vim.lsp.get_clients({ bufnr = context.bufnr, name = "vtsls" })
                            if #clients == 0 then
                                vim.notify(
                                    "Could not find `vtsls` lsp client, `vue_ls` would not work without it.",
                                    vim.log.levels.ERROR
                                )
                                return
                            end
                            local ts_client = clients[1]

                            local param = unpack(result)
                            local id, command, payload = unpack(param)
                            ts_client:exec_cmd({
                                -- You can give title anything as it's used to represent a command in the UI, `:h Client:exec_cmd`
                                title = "vue_request_forward",
                                command = "typescript.tsserverRequest",
                                arguments = {
                                    command,
                                    payload,
                                },
                            }, { bufnr = context.bufnr }, function(_, r)
                                local response_data = { { id, r.body } }
                                ---@diagnostic disable-next-line: param-type-mismatch
                                client:notify("tsserver/response", response_data)
                            end)
                        end
                    end,
                }
            end
            return vim.tbl_deep_extend("force", opts, {
                ---@type table<string,vim.lsp.ConfigLocal>
                servers = servers,
            })
        end,
    },
}

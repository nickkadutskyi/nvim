local vue_language_server_path = "/path/to/@vue/language-server"
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
    {
        "nvim-lspconfig",
        opts = {
            ---@type table<string,vim.lsp.ConfigLocal>
            servers = {
                ["vue_ls"] = {
                    init_options = {
                        vue = {
                            hybridMode = true,
                        },
                    },
                },
            },
        },
    },
    {
        "neovim/nvim-lspconfig",
        opts = function(_, opts)
            table.insert(opts.servers.vtsls.filetypes, "vue")
            Utils.extend(opts.servers.vtsls, "settings.vtsls.tsserver.globalPlugins", {
                {
                    name = "@vue/typescript-plugin",
                    location = "",
                    -- location = Utils.get_pkg_path("vue-language-server", "/node_modules/@vue/language-server"),
                    -- location = "vue-language-server",
                    languages = { "vue" },
                    configNamespace = "typescript",
                    enableForWorkspaceTypeScriptVersions = true,
                },
            })
        end,
    },
}

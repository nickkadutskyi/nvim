---@type LazySpec
return {
    {
        "nvim-lspconfig",
        opts = function(_, opts)
            local servers = {}
            if Utils.tools.is_component_enabled("vue", "vue_ls", Utils.tools.purpose.LSP) then
                -- See https://github.com/vuejs/language-tools/wiki/Neovim for Vue language server setup
                local vue_plugin = {
                    name = "@vue/typescript-plugin",
                    location = vim.fn.getcwd() .. "/node_modules/@vue/language-server",
                    languages = { "vue" },
                    configNamespace = "typescript",
                    enableForWorkspaceTypeScriptVersions = true,
                }

                -- Vtsls plugin setup
                if Utils.tools.is_component_enabled("typescript", "vtsls", Utils.tools.purpose.LSP) then
                    Utils.extend(opts.servers.vtsls, "filetypes", { "vue" })
                    Utils.extend(opts.servers.vtsls, "settings.vtsls.tsserver.globalPlugins", {
                        vue_plugin,
                    })
                -- TS Server plugin setup
                elseif
                    Utils.tools.is_component_enabled("typescript", "ts_ls", Utils.tools.purpose.LSP)
                    or Utils.tools.is_component_enabled("javascript", "ts_ls", Utils.tools.purpose.LSP)
                then
                    Utils.extend(opts.servers.ts_ls, "filetypes", { "vue" })
                    Utils.extend(opts.servers.ts_ls, "init_options.plugins", {
                        vue_plugin,
                    })
                end

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

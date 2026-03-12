---@type LazySpec
return {
    {
        "nvim-lspconfig",
        opts = function(_, opts)
            local servers = {}

            -- Typescript & Javascript Language Server
            servers = Utils.tools.extend_if_enabled(servers, {
                ["ts_ls"] = Utils.js.servers.ts_ls,
            }, {
                "javascript",
                "ts_ls",
                Utils.tools.purpose.LSP,
                { "jsconfig.json" },
            })
            -- Eslint
            servers = Utils.tools.extend_if_enabled(servers, {
                ["eslint"] = Utils.js.servers.eslint,
            }, {
                "javascript",
                "eslint",
                Utils.tools.purpose.LSP,
                { "eslint.config.js", "eslint.config.mjs", "eslint.config.cjs" },
            })

            return vim.tbl_deep_extend("force", opts, {
                ---@type table<string,vim.lsp.ConfigLocal>
                servers = servers,
            })
        end,
    },
}

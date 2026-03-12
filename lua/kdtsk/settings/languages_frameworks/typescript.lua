---@type LazySpec
return {
    {
        "nvim-lspconfig",
        opts = function(_, opts)
            ---@type table<string,vim.lsp.ConfigLocal>
            local servers = {}

            -- Eslint
            servers = Utils.tools.extend_if_enabled(servers, {
                ["eslint"] = Utils.js.servers.eslint,
            }, {
                "typescript",
                "eslint",
                Utils.tools.purpose.LSP,
                { "eslint.config.ts", "eslint.config.mts", "eslint.config.cts" },
            })

            -- NOTE: Use either ts_ls or vtsls, not both, since they will conflict with each other. vtsls is preferred since
            -- it provides better support for Vue projects, but ts_ls is more stable and has better support for pure
            -- Typescript projects.

            -- Typescript & Javascript Language Server
            servers = Utils.tools.extend_if_enabled(servers, {
                ["ts_ls"] = Utils.js.servers.ts_ls,
            }, {
                "typescript",
                "ts_ls",
                Utils.tools.purpose.LSP,
                { "tsconfig.json" },
            })

            -- Vtsls
            servers = Utils.tools.extend_if_enabled(servers, {
                ["vtsls"] = Utils.js.servers.vtsls,
            }, {
                "typescript",
                "vtsls",
                Utils.tools.purpose.LSP,
            })
            servers = Utils.tools.extend_if_enabled(servers, {
                ["vtsls"] = Utils.js.servers.vtsls,
            }, {
                "vue",
                "vue_ls",
                Utils.tools.purpose.LSP,
            })

            return vim.tbl_deep_extend("force", opts, {
                ---@type table<string,vim.lsp.ConfigLocal>
                servers = servers,
            })
        end,
    },
}

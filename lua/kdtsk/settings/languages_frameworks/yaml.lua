---@type LazySpec
return {
    {
        "conform.nvim", -- Code Style
        opts = function(_, opts)
            local fmt_conf = {}

            -- PHP Code Sniffer Beautifier
            fmt_conf = Utils.tools.extend_if_enabled(fmt_conf, { "yamlfmt" }, {
                "yaml",
                "yamlfmt",
                Utils.tools.purpose.STYLE,
                { ".yamlfmt" },
            })

            return vim.tbl_deep_extend("force", opts, {
                formatters_by_ft = { yaml = fmt_conf },
                formatters = {},
            })
        end,
    },
    {
        "nvim-lspconfig", -- Language Servers
        opts = {
            ---@type table<string,vim.lsp.ConfigLocal>
            servers = {
                yamlls = {
                    enabled = Utils.tools.is_component_enabled("yaml", "yamlls", Utils.tools.purpose.LSP),
                },
            },
        },
    },
}

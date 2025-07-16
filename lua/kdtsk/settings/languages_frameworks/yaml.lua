---@type LazySpec
return {
    {
        "nvim-treesitter", -- Color Scheme
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, {
                "yaml",
            })
        end,
    },
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
        "nvim-lint", -- Quality Tools
        opts = function(_, opts)
            local lint_conf = {}

            -- YAMLLint
            lint_conf = Utils.tools.extend_if_enabled(lint_conf, { "yamllint" }, {
                "yaml",
                "yamllint",
                Utils.tools.purpose.INSPECTION,
                { ".yamllint", ".yamllint.yaml", ".yamllint.yml" },
            })

            return vim.tbl_deep_extend("force", opts, {
                ---@type table<string, string[]>
                linters_by_ft = { yaml = lint_conf },
                ---@type table<string, lint.LinterLocal>
                linters = {},
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

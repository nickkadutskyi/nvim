---@type LazySpec
return {
    { -- Color Scheme
        "nvim-treesitter",
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, {
                "zig",
            })
        end,
    },
    { -- Code Style
        "conform.nvim",
        opts = {
            formatters_by_ft = {
                zig = { "zigfmt", lsp_format = "fallback" },
            },
        },
    },
    { -- Quality Tools (moved to LSP)
        "nvim-lint",
        opts = function(_, opts)
            local lint_conf = {}

            -- PHP Code Sniffer
            lint_conf = Utils.tools.extend_if_enabled(lint_conf, { "zig" }, {
                "zig",
                "zig",
                Utils.tools.purpose.INSPECTION,
            })

            return vim.tbl_deep_extend("force", opts, {
                ---@type table<string, string[]>
                linters_by_ft = { php = lint_conf },
                ---@type table<string, lint.LinterLocal>
                linters = {},
            })
        end,
    },
    { -- Language Servers
        "nvim-lspconfig",
        opts = {
            ---@type table<string,vim.lsp.ConfigLocal>
            servers = {
                zls = {
                    enabled = Utils.tools.is_component_enabled("zig", "zls", Utils.tools.purpose.LSP, { "zls.json" }),
                },
            },
        },
    },
}

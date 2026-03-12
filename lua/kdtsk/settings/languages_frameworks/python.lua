---@type LazySpec
return {
    { -- Code Style
        "conform.nvim",
        opts = function(_, opts)
            local fmt_conf = {}

            fmt_conf = Utils.tools.extend_if_enabled(fmt_conf, { "isort" }, {
                "python",
                "isort",
                Utils.tools.purpose.STYLE,
                { ".isort.cfg" },
            })

            fmt_conf = Utils.tools.extend_if_enabled(fmt_conf, { "black" }, {
                "python",
                "black",
                Utils.tools.purpose.STYLE,
            })

            return vim.tbl_deep_extend("force", opts, {
                formatters_by_ft = { python = fmt_conf },
                formatters = {},
            })
        end,
    },
    { -- Language Servers
        "nvim-lspconfig",
        opts = {
            ---@type table<string,vim.lsp.ConfigLocal>
            servers = {
                pylsp = {
                    nix_pkg = "python313Packages.python-lsp-server", -- pylsp
                    enabled = Utils.tools.is_component_enabled("python", "pylsp", Utils.tools.purpose.LSP),
                },
                pyright = {
                    nix_pkg = "pyright", -- pyright-langserver
                    enabled = Utils.tools.is_component_enabled("python", "pyright", Utils.tools.purpose.LSP, {
                        "pyrightconfig.json",
                    }),
                },
            },
        },
    },
}

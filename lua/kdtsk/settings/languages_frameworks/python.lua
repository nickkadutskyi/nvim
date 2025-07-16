---@type LazySpec
return {
    { -- Color Scheme
        "nvim-treesitter",
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, {
                "python",
            })
        end,
    },
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
    { -- Quality Tools
        "nvim-lint",
        opts = function(_, opts)
            local lint_conf = {}

            -- Ruff
            lint_conf = Utils.tools.extend_if_enabled(lint_conf, { "ruff" }, {
                "python",
                "ruff",
                Utils.tools.purpose.INSPECTION,
                { "ruff.toml", ".ruff.toml" },
            })
            -- Flake8
            lint_conf = Utils.tools.extend_if_enabled(lint_conf, { "flake8" }, {
                "python",
                "flake8",
                Utils.tools.purpose.INSPECTION,
                { ".flake8" },
            })
            -- Pylint
            lint_conf = Utils.tools.extend_if_enabled(lint_conf, { "pylint" }, {
                "python",
                "pylint",
                Utils.tools.purpose.INSPECTION,
            })

            return vim.tbl_deep_extend("force", opts, {
                ---@type table<string, string[]>
                linters_by_ft = { python = lint_conf },
                ---@type table<string, lint.LinterLocal>
                linters = {
                    flake8 = { nix_pkg = "python313Packages.flake8" },
                },
            })
        end,
    },
}

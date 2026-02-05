---@type LazySpec
return {
    { -- Color Scheme
        "nvim-treesitter",
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, {
                "twig",
            })
        end,
    },
    {
        "conform.nvim", -- Code Style
        opts = function(_, opts)
            local util = require("conform.util")
            local fmt_conf_twig = {
                async = true,
                timeout_ms = 1500,
            }

            fmt_conf_twig = Utils.tools.extend_if_enabled(fmt_conf_twig, { "twig-cs-fixer" }, {
                "twig",
                "twig-cs-fixer",
                Utils.tools.purpose.STYLE,
                { ".twig-cs-fixer.dist.php", ".twig-cs-fixer.php", "symfony.lock" },
            })

            return vim.tbl_deep_extend("force", opts, {
                formatters_by_ft = { twig = fmt_conf_twig },
                formatters = {
                    ["twig-cs-fixer"] = {
                        command = function(_, ctx)
                            return Utils.php.find_executable("twig-cs-fixer", ctx.dirname) or "twig-cs-fixer"
                        end,
                        cwd = util.root_file({
                            ".twig-cs-fixer.php",
                            ".twig-cs-fixer.dist.php",
                            "symfony.lock",
                            "composer.json",
                        }),
                    },
                },
            })
        end,
    },
    {
        "nvim-lint", -- Quality Tools
        event = { "BufReadPre", "BufNewFile" },
        opts = function(_, opts)
            local lint_conf = {}

            -- Twig-CS-Fixer
            lint_conf = Utils.tools.extend_if_enabled(lint_conf, { "twig-cs-fixer" }, {
                "twig",
                "twig-cs-fixer",
                Utils.tools.purpose.INSPECTION,
                { ".twig-cs-fixer.dist.php", ".twig-cs-fixer.php", "symfony.lock" },
            })

            return vim.tbl_deep_extend("force", opts, {
                ---@type table<string, string[]>
                linters_by_ft = { twig = lint_conf },
                ---@type table<string, lint.LinterLocal>
                linters = {},
            })
        end,
    },
}

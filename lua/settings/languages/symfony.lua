local spec = require("ide.spec.builder")

spec.add({ "nvim-treesitter", opts = { ensure_installed = { "twig" } } })

spec.add({
    "nvim-lint",
    ---@type ide.Opts.Lint
    opts = {
        linters_by_ft = {
            twig = { { "twig-cs-fixer", { ".twig-cs-fixer.dist.php", ".twig-cs-fixer.php", "symfony.lock" } } },
        },
    },
})

spec.add({
    "conform.nvim", -- Code Style
    ---@type ide.Opts.Conform
    opts = {
        formatters_by_ft = {
            twig = {
                { "_", nil, nil, true, { async = true, timeout_ms = 1500, stop_after_first = false } },
                {
                    "prettierd",
                    { ".prettierrc", ".prettierrc.json", ".prettierrc.js", ".prettierrc.yaml", ".prettierrc.yml" },
                },
                { "prettier" },
                { "twig-cs-fixer", { ".twig-cs-fixer.dist.php", ".twig-cs-fixer.php", "symfony.lock" } },
            },
        },
        conform_opts = {
            formatters = {
                ["twig-cs-fixer"] = {
                    command = function(_, ctx)
                        return Utils.php.find_executable("twig-cs-fixer", ctx.dirname) or "twig-cs-fixer"
                    end,
                    cwd = function(...)
                        local util = require("conform.util")
                        return util.root_file({
                            ".twig-cs-fixer.php",
                            ".twig-cs-fixer.dist.php",
                            "symfony.lock",
                            "composer.json",
                        })(...) or vim.fn.getcwd()
                    end,
                },
            },
        },
    },
})

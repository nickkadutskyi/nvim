local spec = require("ide.spec.builder")

spec.add({ "nvim-treesitter", opts = { ensure_installed = { "php", "phpdoc" } } })

spec.add({
    "nvim-lint",
    ---@type ide.Opts.Lint
    opts = {
        linters_by_ft = {
            php = {
                { "php", nil, nil, true },
                { "phpcs", { ".phpcs.xml", "phpcs.xml" } },
                { "phpinsights", { "phpinsights.php" } },
                { "phpm", { "phpmd.xml" } },
                { "phpstan", { "phpstan.neon", "phpstan.neon.dist", "phpstan.dist.neon" } },
                -- TODO: Consider providing a function that will check if it's enabled via LSP
                -- Explicitly disable it via .editorconfig since might use it via LSP
                { "psalm", { "psalm.xml", "psalm.xml.dist" } },
            },
        },
        -- TODO: move php linters from kdtsk to ide utils
        linters = {
            phpcs = Utils.php.linters.phpcs,
            phpmd = Utils.php.linters.phpmd,
            phpstan = Utils.php.linters.phpstan,
            psalm = Utils.php.linters.psalm,
            phpinsights = {
                cmd = function()
                    return Utils.php.find_executable("phpinsights") or "phpinsights"
                end,
                nix_pkg = "php84Packages.phpinsights",
            },
        },
    },
})

spec.add({
    "conform.nvim",
    opts = { ---@type ide.Opts.Conform
        formatters_by_ft = {
            php = {
                { "_", nil, nil, true, { async = true, timeout_ms = 1500 } },
                { "_intelephense", { ".jsbeautifyrc" }, nil, nil, { lsp_format = "first" } },
                { "phpcbf", { ".phpcs.xml", "phpcs.xml" } },
                {
                    "php_cs_fixer",
                    { ".php-cs-fixer.dist.php", ".php-cs-fixer.php" },
                    function()
                        -- only enable if we find an executable in the project
                        local executable = "php-cs-fixer"
                        local cwd = vim.uv.cwd()

                        -- Only look for local executables
                        local _, found = Utils.tools.find_executable({
                            "./" .. executable,
                            "./" .. executable .. ".phar",
                            "vendor/bin/" .. executable,
                            "vendor/bin/" .. executable .. ".phar",
                            ".devenv/profile/bin/" .. executable,
                        }, executable .. "_", cwd)

                        return found
                    end,
                },
            },
        },
        conform_opts = {
            formatters = {
                php_cs_fixer = {
                    -- because I have projects with two composer configs
                    cwd = function()
                        local util = require("conform.util")
                        util.root_file({ "php-cs-fixer.dist.php", ".git" })
                    end,
                    command = function(_, ctx)
                        return Utils.php.find_executable("php-cs-fixer", ctx.dirname) or "php-cs-fixer"
                    end,
                    options = {
                        nix_pkg = "php83Packages.php-cs-fixer",
                        cmd = "php-cs-fixer",
                    },
                },
                phpcbf = {
                    command = function(_, ctx)
                        return Utils.php.find_executable("phpcbf", ctx.dirname) or "phpcbf"
                    end,
                    options = {
                        nix_pkg = "php84Packages.php-codesniffer",
                        cmd = "phpcbf",
                    },
                },
            },
        },
    },
})

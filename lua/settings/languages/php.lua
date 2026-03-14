local spec = require("ide.spec.builder")
local utils = require("ide.utils")

spec.add({ "nvim-treesitter", opts = { ensure_installed = { "php", "phpdoc" } } })

spec.add({
    "nvim-lint",
    opts = { ---@type ide.Opts.Lint
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
                    cwd = function(...)
                        local util = require("conform.util")
                        return util.root_file({ "php-cs-fixer.dist.php", ".git" })(...)
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

spec.add({
    "nvim-lspconfig",
    opts = { ---@type ide.Opts.Lsp
        clients = {
            ["intelephense"] = {
                enabled = {
                    { ".intelephense.json", "intelephense.json", ".intelephense/config.json" },
                    function() -- Always enabe if there is executable in the project
                        return utils.tool.find_php_executable("intelephense") ~= nil
                    end,
                },
                nix_pkg = "intelephense",
                bin = function()
                    return utils.tool.find_php_executable("intelephense")
                end,
                init_options = {
                    licenceKey = vim.fn.expand("/run/secrets/php/intelephense_license"),
                },
                settings = {
                    intelephense = {
                        telemetry = {
                            enabled = false,
                        },
                        files = {
                            exclude = {
                                -- These are causing high CPU usage
                                "**/.devenv/**",
                                "**/.direnv/**",
                                "**/.jj/**",
                                "**/.idea/**",
                                "**/.git/**",
                                "**/.svn/**",
                                "**/.hg/**",
                                "**/CVS/**",
                                "**/.DS_Store/**",
                                "**/node_modules/**",
                                "**/bower_components/**",
                                "**/vendor/**/{Tests,tests}/**",
                                "**/.history/**",
                                "**/vendor/**/vendor/**",
                                -- This is for WordPress Starter Projects
                                "**/public/wp/**",
                                "**/public/content/plugins/vendor-**",
                                "**/public/content/mu-plugins/vendor-**",
                                "**/public/content/themes/vendor-**",
                            },
                            maxSize = 10000000,
                        },
                    },
                },
            },
            ["phan"] = {
                -- To enable it create .phan/config.php with contents
                enabled = { { ".phan/config.php" } },
                nix_pkg = "php85Packages.phan",
                bin = function()
                    return utils.tool.find_php_executable("phan")
                end,
            },
            ["phpactor"] = {
                -- Requires proper project root files (composer.json, .git, .phpactor.json, .phpactor.yml)
                -- Use it if executable is provided and if there is proper root
                -- To enable it create either .phpactor.json or .phpactor.yml with contents
                enabled = { { ".phpactor.json", ".phpactor.yml" } },
                nix_pkg = "phpactor",
                bin = function()
                    return utils.tool.find_php_executable("phpactor")
                end,
            },
            ["psalm"] = {
                -- `root_dir` already checks for psalm.xml or psalm.xml.dist
                -- To enable it create either of these files and configure it
                enabled = { { "psalm.xml", "psalm.xml.dist" } },
                nix_pkg = "php85Packages.psalm",
                bin = function()
                    return utils.tool.find_php_executable("psalm")
                end,
            },
        },
    },
})

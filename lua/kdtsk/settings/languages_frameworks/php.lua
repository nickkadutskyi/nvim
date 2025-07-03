---@type LazySpec
return {
    {
        "nvim-treesitter", -- Color Scheme
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, {
                "php",
                "phpdoc",
            })
        end,
    },
    {
        "nvim-lspconfig", -- Language Servers
        opts = function(_, opts)
            return vim.tbl_deep_extend("force", opts, {
                ---@type table<string,vim.lsp.ConfigLocal>
                servers = {
                    ["intelephense"] = {
                        enabled = Utils.tools.is_component_enabled("php", "intelephense", Utils.tools.purpose.LSP, {
                            ".intelephense.json",
                            ".intelephense/config.json",
                        }),
                        local_config = ".intelephense.json",
                        nix_pkg = "intelephense",
                        bin = Utils.php.find_executable("intelephense"),
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
                                    },
                                    maxSize = 10000000,
                                },
                            },
                        },
                    },
                    ["phan"] = {
                        -- `root_dir` already checks for composer.json and .git
                        -- To enable it create .phan/config.php with contents
                        enabled = Utils.tools.is_component_enabled("php", "phan", Utils.tools.purpose.LSP, {
                            ".phan/config.php",
                        }),
                        nix_pkg = "php84Packages.phan",
                        bin = Utils.php.find_executable("phan"),
                    },
                    ["phpactor"] = {
                        -- Requires proper project root files (composer.json, .git, .phpactor.json, .phpactor.yml)
                        -- Use it if executable is provided and if there is proper root
                        -- To enable it create either .phpactor.json or .phpactor.yml with contents
                        enabled = Utils.tools.is_component_enabled("php", "phpactor", Utils.tools.purpose.LSP, {
                            ".phpactor.json",
                            ".phpactor.yml",
                        }),
                        nix_pkg = "phpactor",
                        bin = Utils.php.find_executable("phpactor"),
                    },
                    ["psalm"] = {
                        -- `root_dir` already checks for psalm.xml or psalm.xml.dist
                        -- To enable it create either of these files and configure it
                        enabled = Utils.tools.is_component_enabled("php", "psalm", Utils.tools.purpose.LSP, {
                            "psalm.xml",
                            "psalm.xml.dist",
                        }),
                        nix_pkg = "php84Packages.psalm",
                        bin = Utils.php.find_executable("psalm"),
                    },
                },
            })
        end,
    },
    {
        "conform.nvim", -- Code Style
        opts = function(_, opts)
            local util = require("conform.util")
            local fmt_conf = {
                async = true,
                timeout_ms = 500,
            }

            -- PHP Code Sniffer Beautifier
            fmt_conf = Utils.tools.extended_if_enabled(fmt_conf, { "phpcbf" }, {
                "php",
                "phpcbf",
                Utils.tools.purpose.STYLE,
                { ".phpcs.xml", "phpcs.xml" },
            })

            -- PHP CS Fixer
            fmt_conf = Utils.tools.extended_if_enabled(fmt_conf, { "php_cs_fixer" }, {
                "php",
                "php_cs_fixer",
                Utils.tools.purpose.STYLE,
                { ".php-cs-fixer.dist.php" },
            })

            -- Intelephense as formatter
            -- runs jsbeautify via intelephense so it's useful to have .jsbeautifyrc
            fmt_conf = Utils.tools.extended_if_enabled(fmt_conf, { lsp_format = "first" }, {
                "php",
                "intelephense",
                Utils.tools.purpose.STYLE,
                { ".jsbeautifyrc" },
            })

            return vim.tbl_deep_extend("force", opts, {
                formatters_by_ft = { php = fmt_conf },
                formatters = {
                    php_cs_fixer = {
                        -- because I have projects with two composer configs
                        cwd = util.root_file({ "php-cs-fixer.dist.php", ".git" }),
                        command = util.find_executable({
                            "tools/php-cs-fixer/vendor/bin/php-cs-fixer",
                            "vendor/bin/php-cs-fixer",
                            ".devenv/profile/bin/php-cs-fixer",
                        }, "php-cs-fixer"),
                        options = {
                            nix_pkg = "php84Packages.php-cs-fixer",
                            cmd = "php-cs-fixer",
                        },
                    },
                    phpcbf = {
                        command = util.find_executable({
                            "vendor/bin/phpcbf",
                            ".devenv/profile/bin/phpcbf",
                        }, "phpcbf"),
                        options = {
                            nix_pkg = "php84Packages.php-codesniffer",
                            cmd = "phpcbf",
                        },
                    },
                },
            })
        end,
    },
    {
        "nvim-lint", -- Quality Tools
        event = { "BufReadPre", "BufNewFile" },
        opts = function(_, opts)
            local lint_conf = {
                "php", -- always use php as linter
            }

            -- PHP Code Sniffer
            lint_conf = Utils.tools.extended_if_enabled(lint_conf, { "phpcs" }, {
                "php",
                "phpcs",
                Utils.tools.purpose.INSPECTION,
                { ".phpcs.xml", "phpcs.xml" },
            })

            -- PHP Insights
            lint_conf = Utils.tools.extended_if_enabled(lint_conf, { "phpinsights" }, {
                "php",
                "phpinsights",
                Utils.tools.purpose.INSPECTION,
                { "phpinsights.php" },
            })

            -- PHP Mess Detector
            lint_conf = Utils.tools.extended_if_enabled(lint_conf, { "phpmd" }, {
                "php",
                "phpmd",
                Utils.tools.purpose.INSPECTION,
                { "phpmd.xml" },
            })

            -- PHPStan
            lint_conf = Utils.tools.extended_if_enabled(lint_conf, { "phpstan" }, {
                "php",
                "phpstan",
                Utils.tools.purpose.INSPECTION,
                { "phpstan.neon", "phpstan.neon.dist", "phpstan.dist.neon" },
            })

            -- Psalm
            lint_conf = Utils.tools.extended_if_enabled(lint_conf, { "psalm" }, {
                "php",
                "psalm",
                Utils.tools.purpose.INSPECTION,
                -- only explicitly enable via settings since using it via LSP
                -- { "psalm.xml", "psalm.xml.dist" },
            })

            return vim.tbl_deep_extend("force", opts, {
                ---@type table<string, string[]>
                linters_by_ft = { php = lint_conf },
                ---@type table<string, lint.LinterLocal>
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
            })
        end,
    },
}

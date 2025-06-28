---@type LazySpec
return {
    { -- Color Scheme
        "nvim-treesitter",
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, {
                "php",
                "phpdoc",
            })
        end,
    },
    { -- Language Servers
        "nvim-lspconfig",
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
    { -- Code Style
        "conform.nvim",
        opts = function(_, opts)
            local util = require("conform.util")
            local formatters_to_use = {}
            -- PHP Code Sniffer
            if
                Utils.tools.is_component_enabled("php", "phpcbf", Utils.tools.purpose.STYLE, {
                    ".phpcs.xml",
                    "phpcs.xml",
                    ".phpcs.xml.dist",
                    "phpcs.xml.dist",
                })
            then
                table.insert(formatters_to_use, "phpcbf")
            end
            -- PHP CS Fixer
            if
                Utils.tools.is_component_enabled("php", "php_cs_fixer", Utils.tools.purpose.STYLE, {
                    ".php-cs-fixer.dist.php",
                })
            then
                table.insert(formatters_to_use, "php_cs_fixer")
            end
            -- Intelephense as formatter
            -- runs jsbeautify via intelephense so it's useful to have .jsbeautifyrc
            if
                Utils.tools.is_component_enabled("php", "intelephense", Utils.tools.purpose.STYLE, {
                    ".jsbeautifyrc",
                })
            then
                formatters_to_use["lsp_format"] = "first"
            end

            return vim.tbl_deep_extend("force", opts, {
                formatters_by_ft = {
                    php = vim.tbl_extend("force", formatters_to_use, {
                        async = true,
                        timeout_ms = 500,
                    }),
                },
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
    { -- Quality Tools
        "nvim-lint",
        event = { "BufReadPre", "BufNewFile" },
        -- TODO: implement on/off logic based on presence of config files or
        --       other things
        opts = {
            ---@type table<string, string[]>
            linters_by_ft = {
                php = {
                    "php",
                    "phpcs",
                    "phpmd",
                    "phpstan",
                    -- "psalm",
                },
            },
            ---@type table<string, lint.LinterLocal>
            linters = {

                -- TODO: implement this https://docs.wpvip.com/php_codesniffer/phpcs-report/
                -- PHP Code Sniffer
                phpcs = {
                    cmd = function()
                        return Utils.php.find_executable("phpcs") or "phpcs"
                    end,
                    nix_pkg = "php84Packages.php-codesniffer",
                    -- Sets col and end_col to whole row
                    parser = function(output, bufnr)
                        local severities = {
                            ERROR = vim.diagnostic.severity.ERROR,
                            WARNING = vim.diagnostic.severity.WARN,
                        }

                        local bin = "phpcs"
                        if vim.trim(output) == "" or output == nil then
                            return {}
                        end

                        local diagnostics = {}
                        local decoded = vim.json.decode(output)
                        for _, result in pairs(decoded.files) do
                            for _, msg in ipairs(result.messages or {}) do
                                local lnum = type(msg.line) == "number" and (msg.line - 1) or 0
                                local linecont = vim.api.nvim_buf_get_lines(bufnr, lnum, lnum + 1, false)[1] or ""
                                local col = linecont:match("()%S") or 1
                                local end_col = linecont:match(".*%S()") or 1
                                table.insert(diagnostics, {
                                    lnum = lnum,
                                    col = col - 1,
                                    end_col = end_col,
                                    message = msg.message,
                                    code = msg.source,
                                    source = bin,
                                    severity = assert(
                                        severities[msg.type],
                                        "missing mapping for severity " .. msg.type
                                    ),
                                })
                            end
                        end
                        return diagnostics
                    end,
                },

                -- PHP Mess Detector
                phpmd = {
                    cmd = function()
                        return Utils.php.find_executable("phpmd") or "phpmd"
                    end,
                    args = {
                        "-",
                        "json",
                        "./phpmd.xml",
                    },
                    nix_pkg = "php84Packages.phpmd",
                    -- Adds this only to strip deprecations from output
                    parser = function(output, _)
                        local bin = "phpmd"
                        local severities = {}
                        severities[1] = vim.diagnostic.severity.ERROR
                        severities[2] = vim.diagnostic.severity.WARN
                        severities[3] = vim.diagnostic.severity.INFO
                        severities[4] = vim.diagnostic.severity.HINT
                        severities[5] = vim.diagnostic.severity.HINT

                        if vim.trim(output) == "" or output == nil then
                            return {}
                        end

                        local ok
                        ok, output = Utils.linter_phpmd.strip_deprecations(output)

                        if not vim.startswith(output, "{") or not ok then
                            vim.notify(output)
                            return {}
                        end

                        local decoded = vim.json.decode(output)
                        local diagnostics = {}
                        local messages = {}

                        if decoded["files"] and decoded["files"][1] and decoded["files"][1]["violations"] then
                            messages = decoded["files"][1]["violations"]
                        end

                        for _, msg in ipairs(messages or {}) do
                            table.insert(diagnostics, {
                                lnum = msg.beginLine - 1,
                                end_lnum = msg.endLine - 1,
                                col = 0,
                                end_col = 0,
                                message = msg.description,
                                code = msg.rule,
                                source = bin,
                                severity = assert(
                                    severities[msg.priority],
                                    "missing mapping for severity " .. msg.priority
                                ),
                            })
                        end

                        return diagnostics
                    end,
                },

                -- PHPStan
                phpstan = {
                    cmd = function()
                        return Utils.php.find_executable("phpstan") or "phpstan"
                    end,
                    nix_pkg = "php84Packages.phpstan",
                    -- Sets col and end_col to whole row
                    parser = function(output, bufnr)
                        if vim.trim(output) == "" or output == nil then
                            return {}
                        end

                        local file = vim.json.decode(output).files[vim.api.nvim_buf_get_name(bufnr)]

                        if file == nil then
                            return {}
                        end

                        local diagnostics = {}

                        for _, message in ipairs(file.messages or {}) do
                            local lnum = type(message.line) == "number" and (message.line - 1) or 0
                            local linecont = vim.api.nvim_buf_get_lines(bufnr, lnum, lnum + 1, false)[1] or ""
                            local col = linecont:match("()%S") or 0
                            local end_col = linecont:match(".*%S()") or 0
                            table.insert(diagnostics, {
                                lnum = lnum,
                                col = col - 1,
                                end_col = end_col - 1,
                                code = message.identifier or "", -- only works for phpstan >= 1.11
                                message = message.message,
                                source = "phpstan",
                                severity = vim.diagnostic.severity.ERROR,
                            })
                        end

                        return diagnostics
                    end,
                },

                -- Psalm
                psalm = {
                    cmd = function()
                        return Utils.php.find_executable("psalm") or "psalm"
                    end,
                    nix_pkg = "php84Packages.psalm",
                    -- Psalm exits with 2 when there are issues in file
                    ignore_exitcode = true,
                    -- Adds type, link and shortcote to diagnostics entries
                    parser = function(output, bufnr)
                        if output == nil then
                            return {}
                        end

                        local filename = vim.api.nvim_buf_get_name(bufnr)

                        local messages = vim.json.decode(output)
                        local diagnostics = {}

                        for _, message in ipairs(messages or {}) do
                            if message.file_path == filename then
                                table.insert(diagnostics, {
                                    lnum = message.line_from - 1,
                                    end_lnum = message.line_to - 1,
                                    col = message.column_from - 1,
                                    end_col = message.column_to - 1,
                                    message = message.message,
                                    code = message.type .. " " .. message.link,
                                    source = "psalm",
                                    severity = message.severity,
                                })
                            end
                        end

                        return diagnostics
                    end,
                },
            },
        },
    },
}

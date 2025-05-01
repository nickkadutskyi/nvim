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
        opts = {
            ---@type table<string,lspconfig.ConfigPartial>
            servers = {
                ["intelephense"] = {
                    enabled = false, -- due to high CPU usage
                    init_options = {
                        licenceKey = vim.fn.expand("/run/secrets/php/intelephense_license"),
                    },
                    settings = {
                        intelephense = {
                            telemetry = {
                                enabled = false,
                            },
                            files = {
                                maxSize = 1000000,
                            },
                        },
                    },
                },
                ["phpactor"] = {
                    enabled = true,
                },
                ["psalm"] = {
                    enabled = false, -- nix package throws runtime PHP error, use as CLI tool
                    nix_pkg = "php83Packages.psalm",
                    cmd = { "psalm", "--language-server", "--config=psalm.xml" },
                },
            },
        },
    },
    { -- Code Style
        "conform.nvim",
        opts = function(_, opts)
            local util = require("conform.util")
            return vim.tbl_deep_extend("force", opts, {
                formatters_by_ft = {
                    php = {
                        "phpcbf",
                        "php_cs_fixer",
                        -- if phpcbf is used as both linter and formatter there is no need for php-cs-fixer
                        -- so it's safe to have this options since only one of them will be used
                        -- but need to install them locally for a project only
                        -- stop_after_first = true,
                        -- runs jsbeautify via intelephense so it's useful to have .jsbeautifyrc
                        lsp_format = "first",
                    },
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
                            nix_pkg = "php83Packages.php-cs-fixer",
                        },
                    },
                    phpcbf = {
                        command = util.find_executable({
                            "vendor/bin/phpcbf",
                            ".devenv/profile/bin/phpcbf",
                        }, "phpcbf"),
                        options = {
                            nix_pkg = "php83Packages.php-codesniffer",
                        },
                    },
                },
            })
        end,
    },
    { -- Quality Tools
        "nvim-lint",
        event = { "BufReadPre", "BufNewFile" },
        opts = function(_, opts) -- Configure in opts to run all configs for all languages
            local function get_executable(executable)
                return require("nickkadutskyi.utils").find_executable({
                    "vendor/bin/" .. executable,
                    "vendor/bin/" .. executable .. ".phar",
                    ".devenv/profile/bin/" .. executable,
                }, executable)
            end

            return vim.tbl_deep_extend("force", opts, {
                linters_by_ft = {
                    php = {
                        "php",
                        "phpcs",
                        "phpmd",
                        "phpstan",
                        -- Switched to Language Server
                        -- "psalm",
                    },
                },
                linters = {
                    phpcs = { -- Code Sniffer
                        cmd = get_executable("phpcs"),
                        nix_pkg = "php83Packages.php-codesniffer",
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

                            if not vim.startswith(output, "{") then
                                vim.notify(output)
                                return {}
                            end

                            local decoded = vim.json.decode(output)
                            local diagnostics = {}
                            local messages = decoded["files"]["STDIN"]["messages"]

                            for _, msg in ipairs(messages or {}) do
                                local lnum = type(msg.line) == "number" and (msg.line - 1) or 0
                                local linecont = vim.api.nvim_buf_get_lines(bufnr, lnum, lnum + 1, false)[1] or ""
                                -- highlight the whole line
                                local col = linecont:match("()%S") or 0
                                -- local col = msg.column
                                local end_col = linecont:match(".*%S()") or 0
                                table.insert(diagnostics, {
                                    lnum = msg.line - 1,
                                    end_lnum = msg.line - 1,
                                    col = col - 1,
                                    end_col = end_col - 1,
                                    message = msg.message,
                                    code = msg.source,
                                    source = bin,
                                    severity = assert(
                                        severities[msg.type],
                                        "missing mapping for severity " .. msg.type
                                    ),
                                })
                            end

                            return diagnostics
                        end,
                    },
                    phpmd = { -- Mess Detector
                        cmd = get_executable("phpmd"),
                        nix_pkg = "php83Packages.phpmd",
                    },
                    phpstan = { -- PHPStan
                        cmd = get_executable("phpstan"),
                        nix_pkg = "php83Packages.phpstan",
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
                    psalm = { -- Psalm
                        cmd = get_executable("psalm"),
                        nix_pkg = "php83Packages.psalm",
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
            })
        end,
    },
}

local spec = require("ide.spec.builder")
local utils = require("ide.utils")

spec.add({ "nvim-treesitter", opts = { ensure_installed = { "twig" } } })

spec.add({
    "nvim-lint",
    opts = { ---@type ide.Opts.Lint
        linters_by_ft = {
            twig = { { "twig-cs-fixer", { ".twig-cs-fixer.dist.php", ".twig-cs-fixer.php", "symfony.lock" } } },
        },
    },
})

spec.add({
    "conform.nvim",
    opts = { ---@type ide.Opts.Conform
        formatters_by_ft = {
            twig = {
                { "_", nil, nil, true, { async = true, timeout_ms = 1500, stop_after_first = false } },
                {
                    "prettierd",
                    { ".prettierrc", ".prettierrc.json", ".prettierrc.js", ".prettierrc.yaml", ".prettierrc.yml" },
                },
                { "prettier" },
                { "twig-cs-fixer", { ".twig-cs-fixer.dist.php", ".twig-cs-fixer.php", "symfony.lock" } },
                { "djlint", { "djlint.toml", ".djlintrc" }, nil, nil, { timeout_ms = 2000 } },
            },
        },
        conform_opts = {
            formatters = {
                ["twig-cs-fixer"] = {
                    command = function(_, ctx)
                        return utils.tool.find_php_executable("twig-cs-fixer", ctx.dirname) or "twig-cs-fixer"
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

spec.add({
    "nvim-lspconfig",
    opts = { ---@type ide.Opts.Lsp
        clients = {
            ["twiggy_language_server"] = {
                enabled = { { ".twig-cs-fixer.dist.php", ".twig-cs-fixer.php", "symfony.lock" } },
                bin = function()
                    return utils.tool.find_js_executable("twiggy-language-server")
                end,
                settings = {
                    twiggy = {
                        framework = "symfony",
                        phpExecutable = "php",
                        symfonyConsolePath = "bin/console",
                        diagnostics = {
                            twigCsFixer = false,
                        },
                    },
                },
            },
            ["vimfony"] = {
                enabled = {
                    nil,
                    function()
                        return utils.tool.find_php_executable("vimfony") ~= nil
                    end,
                },
                bin = function()
                    return utils.tool.find_php_executable("vimfony")
                end,
                cmd = { "vimfony" },
                filetypes = { "php", "twig", "yaml", "xml" }, -- You can remove file types if you don't like it, but then it won't work in those files
                root_markers = { ".git" },
                single_file_support = true,
                init_options = {
                    roots = { "templates" },
                    container_xml_path = (vim.fn.getcwd() .. "/var/cache/dev/App_KernelDevDebugContainer.xml"),
                    -- OR:
                    -- container_xml_path = {
                    --   (git_root .. "/var/cache/dev/App_KernelDevDebugContainer.xml"),
                    --   (git_root .. "/var/cache/website/dev/App_KernelDevDebugContainer.xml"),
                    --   (git_root .. "/var/cache/admin/dev/App_KernelDevDebugContainer.xml"),
                    -- },
                    vendor_dir = vim.fn.getcwd() .. "/vendor",
                    -- Optional:
                    -- php_path = "/usr/bin/php",
                },
            },
        },
    },
})

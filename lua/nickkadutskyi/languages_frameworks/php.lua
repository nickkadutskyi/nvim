return {
    {
        -- Better highlighting
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, {
                "php",
                "phpdoc",
            })
        end,
    },
    {
        -- Formatting
        "stevearc/conform.nvim",
        opts = function(_, opts)
            local util = require("conform.util")
            return vim.tbl_deep_extend("force", opts, {
                formatters_by_ft = {
                    php = {
                        "php_cs_fixer",
                        "phpcbf",
                        -- if phpcbf is used as both linter and formatter there is no need for php-cs-fixer
                        -- so it's safe to have this options since only one of them will be used
                        -- but need to install them locally for a project only
                        stop_after_first = true,
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
                            -- checks for devenv.sh installation
                            ".devenv/profile/bin/php-cs-fixer",
                        }, "php-cs-fixer"),
                    },
                },
            })
        end,
    },
}

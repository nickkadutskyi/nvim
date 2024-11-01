return {
    {
        "lukas-reineke/virt-column.nvim",
        opts = {
            -- Use highlight groups from nickkadutskyi/jb.nvim
            highlight = {
                "General_Editor_Guides_VisualGuides",
                "General_Editor_Guides_VisualGuides",
                "General_Editor_Guides_HardWrapGuide",
            },
            char = "▕",
        },
    },
    {
        -- Code formatter
        "stevearc/conform.nvim",
        config = function()
            local conform = require("conform")
            local util = require("conform.util")
            conform.setup({
                formatters_by_ft = {
                    lua = { "stylua" },
                    javascript = { "prettierd", "prettier" },
                    css = { "prettierd", "prettier" },
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
                    nix = { "nixfmt" },
                },
                default_format_opts = {
                    lsp_format = "fallback",
                    stop_after_first = true,
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
                    nixfmt = {
                        args = function(_, ctx)
                            local args = {}
                            local editorconfig = vim.fs.find(".editorconfig", { path = ctx.dirname, upward = true })[1]
                            local has_editorconfig = editorconfig ~= nil

                            if has_editorconfig then
                                -- Use grep to find the line containing max_line_length
                                local result = vim.system({
                                    "grep",
                                    "max_line_length",
                                    editorconfig,
                                }):wait()
                                if result.code == 0 then
                                    local line = result.stdout
                                    ---@type string
                                    local len = line ~= nil and line:match("max_line_length%s*=%s*(%d+)") or "120"
                                    args = { "-w", len }
                                end
                            end
                            return args
                        end,
                    },
                },
            })
            vim.keymap.set("n", "<leader>cf", conform.format, { noremap = true })
        end,
    },
    {
        -- Detect tabstop and shiftwidth automatically
        "tpope/vim-sleuth",
    },
}

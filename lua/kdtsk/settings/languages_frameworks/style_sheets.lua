---@type LazySpec
return {
    {
        "nvim-lspconfig",
        opts = {
            ---@type table<string,vim.lsp.ConfigLocal>
            servers = {
                stylelint_lsp = {},
                cssls = {},
            },
        },
    },
    {
        "stevearc/conform.nvim",
        opts = {
            formatters_by_ft = {
                css = { "prettierd", "prettier" },
            },
        },
    },
    {
        -- Code Style
        "conform.nvim",
        opts = function(_, opts)
            local fmt_conf_css = {
                async = true,
                timeout_ms = 1500,
            }
            local fmt_conf_scss = {
                async = true,
                timeout_ms = 1500,
            }

            -- Prettierd
            fmt_conf_css = Utils.tools.extend_if_enabled(fmt_conf_css, { "prettierd" }, {
                "css",
                "prettierd",
                Utils.tools.purpose.STYLE,
                { ".prettierrc", ".prettierrc.json", ".prettierrc.js", ".prettierrc.yaml", ".prettierrc.yml" },
            })
            -- Prettier
            fmt_conf_css = Utils.tools.extend_if_enabled(fmt_conf_css, { "prettier" }, {
                "css",
                "prettier",
                Utils.tools.purpose.STYLE,
            })
            -- Prettierd
            fmt_conf_scss = Utils.tools.extend_if_enabled(fmt_conf_scss, { "prettierd" }, {
                "scss",
                "prettierd",
                Utils.tools.purpose.STYLE,
                { ".prettierrc", ".prettierrc.json", ".prettierrc.js", ".prettierrc.yaml", ".prettierrc.yml" },
            })
            -- Prettier
            fmt_conf_scss = Utils.tools.extend_if_enabled(fmt_conf_scss, { "prettier" }, {
                "scss",
                "prettier",
                Utils.tools.purpose.STYLE,
            })

            return vim.tbl_deep_extend("force", opts, {
                formatters_by_ft = {
                    css = fmt_conf_css,
                    scss = fmt_conf_scss,
                },
                formtters = {
                    prettier = { nix_pkg = "prettier" },
                    prettierd = { nix_pkg = "prettierd" },
                },
            })
        end,
    },
    -- { -- Quality Tools
    --     "nvim-lint",
    --     opts = function()
    --         -- local lint = require("lint")
    --         -- lint.linters_by_ft["css"] = { "stylelint" }
    --         -- lint.linters_by_ft["scss"] = { "stylelint" }
    --         -- Run Style Sheets linters that use stdin
    --         -- vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave", "BufWritePost" }, {
    --         --     group = vim.api.nvim_create_augroup("kdtsk-style-lint-stdin", { clear = true }),
    --         --     pattern = { "*.css", "*.scss" },
    --         --     callback = function(e)
    --         --         lint.try_lint({ "stylelint" })
    --         --     end,
    --         -- })
    --     end,
    -- },
}

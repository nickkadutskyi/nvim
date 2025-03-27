---@type LazySpec
return {
    {
        "nvim-lspconfig",
        opts = {
            servers = {
                stylelint_lsp = {},
                -- somesass_ls = { mason = true },
                cssls = {},
                -- css_variables = { mason = true },
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
    { -- Quality Tools
        "nvim-lint",
        opts = function()
            -- local lint = require("lint")
            -- lint.linters_by_ft["css"] = { "stylelint" }
            -- lint.linters_by_ft["scss"] = { "stylelint" }
            -- Run Style Sheets linters that use stdin
            -- vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave", "BufWritePost" }, {
            --     group = vim.api.nvim_create_augroup("nickkadutskyi-style-lint-stdin", { clear = true }),
            --     pattern = { "*.css", "*.scss" },
            --     callback = function(e)
            --         lint.try_lint({ "stylelint" })
            --     end,
            -- })
        end,
    },
}

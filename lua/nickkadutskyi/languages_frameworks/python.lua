---@type LazySpec
return {
    { -- Color Scheme
        "nvim-treesitter",
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, {
                "python",
            })
        end,
    },
    { -- Code Style
        "stevearc/conform.nvim",
        opts = {
            formatters_by_ft = {
                python = { "isort", "black" },
            },
        },
    },
    { -- Language Servers
        "nvim-lspconfig",
        opts = {
            servers = {
                pylsp = {},
                pyright = {},
            },
        },
    },
    { -- Quality Tools
        "nvim-lint",
        opts = {
            linters_by_ft = {
                python = { "ruff", "flake8", "pylint" },
            },
        },
    },
}

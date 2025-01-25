---@type LazySpec
return {
    { -- Color Scheme
        "nvim-treesitter",
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, {
                "yaml",
            })
        end,
    },
    { -- Code Style
        "conform.nvim",
        opts = {
            formatters_by_ft = {
                yaml = { "yamlfmt" },
            },
        },
    },
    { -- Quality Tools
        "nvim-lint",
        opts = {
            linters_by_ft = {
                yaml = { "yamllint" },
            },
        },
    },
    { -- Language Servers
        "nvim-lspconfig",
        opts = {
            servers = {
                yamlls = {},
            },
        },
    },
}

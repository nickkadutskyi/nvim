---@type LazySpec
return {
    { -- Color scheme enhancement
        "nvim-treesitter",
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, {
                "bash",
            })
        end,
    },
    { -- Language Servers
        "nvim-lspconfig",
        opts = {
            servers = {
                ["bashls"] = {
                    filetypes = { "sh", "zsh" },
                },
            },
        },
    },
    { -- Code Style
        "conform.nvim",
        opts = {
            formatters_by_ft = {
                sh = {
                    "shfmt",
                },
            },
        },
    },
}

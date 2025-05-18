---@type LazySpec
return {
    { -- Color Scheme
        "nvim-treesitter",
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, {
                "ruby",
            })
        end,
    },
    { -- Code Style
        "conform.nvim",
        opts = {
            formatters_by_ft = {
                ruby = { "standardrb", lsp_format = "fallback" },
            },
            formatters = {
                standardrb = {
                    options = {
                        nix_pkg = "rubyPackages.standard",
                    },
                },
            },
        },
    },
    { -- Quality Tools (moved to LSP)
        -- "nvim-lint",
        -- opts = {
        --     linters_by_ft = {
        --         ruby = { "RuboCop", "StandardRB" },
        --     },
        -- },
    },
    { -- Language Servers
        "nvim-lspconfig",
        opts = {
            ---@type table<string,vim.lsp.ConfigLocal>
            servers = {
                rubocop = {}, -- as linter
                ruby_lsp = {},
                solargraph = {},
                standardrb = {
                    nix_pkg = "rubyPackages.standard",
                }, -- as linter
            },
        },
    },
}

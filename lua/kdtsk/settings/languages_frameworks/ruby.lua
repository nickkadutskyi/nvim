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
                rubocop = {
                    enabled = Utils.tools.is_component_enabled(
                        "ruby",
                        "rubocop",
                        Utils.tools.purpose.LSP,
                        { ".rubocop.yml" }
                    ),
                }, -- as linter
                ruby_lsp = {
                    enabled = Utils.tools.is_component_enabled(
                        "ruby",
                        "ruby_lsp",
                        Utils.tools.purpose.LSP,
                        { ".index.yml" }
                    ),
                },
                solargraph = {
                    enabled = Utils.tools.is_component_enabled(
                        "ruby",
                        "solargraph",
                        Utils.tools.purpose.LSP,
                        { ".solargraph.yml" }
                    ),
                },
                standardrb = {
                    enabled = Utils.tools.is_component_enabled("ruby", "standardrb", Utils.tools.purpose.LSP, {}),
                    nix_pkg = "rubyPackages.standard",
                }, -- as linter
            },
        },
    },
}

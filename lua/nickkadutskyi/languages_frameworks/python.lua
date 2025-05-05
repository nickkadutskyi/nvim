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
        "conform.nvim",
        opts = {
            formatters_by_ft = {
                python = { "isort", "black" },
            },
        },
    },
    { -- Language Servers
        "nvim-lspconfig",
        opts = {
            ---@type table<string,vim.lsp.ConfigLocal>
            servers = {
                pylsp = {
                    nix_pkg = "python313Packages.python-lsp-server", -- pylsp
                },
                pyright = {
                    nix_pkg = "pyright", -- pyright-langserver
                },
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

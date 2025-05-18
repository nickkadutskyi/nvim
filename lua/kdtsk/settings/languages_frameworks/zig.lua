---@type LazySpec
return {
    { -- Color Scheme
        "nvim-treesitter",
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, {
                "zig",
            })
        end,
    },
    { -- Code Style
        "conform.nvim",
        opts = {
            formatters_by_ft = {
                zig = { "zigfmt", lsp_format = "fallback" },
            },
        },
    },
    { -- Quality Tools (moved to LSP)
        "nvim-lint",
        opts = {
            linters_by_ft = {
                zig = { "zig" },
            },
        },
    },
    { -- Language Servers
        "nvim-lspconfig",
        opts = {
            ---@type table<string,vim.lsp.ConfigLocal>
            servers = {
                zls = {},
            },
        },
    },
}

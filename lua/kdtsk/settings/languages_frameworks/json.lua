---@type LazySpec
return {
    {
        -- Better highlighting
        "nvim-treesitter",
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, {
                "json",
            })
        end,
    },
    {
        "nvim-lspconfig",
        opts = {
            ---@type table<string,vim.lsp.ConfigLocal>
            servers = {
                ["jsonls"] = {},
            },
        },
    },
    {
        "conform.nvim", -- Code Style
        opts = {
            formatters_by_ft = {
                json = {
                    lsp_format = "first",
                },
            },
        },
    },
}

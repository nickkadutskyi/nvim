---@type LazySpec
return {
    {
        -- Better highlighting
        "nvim-treesitter",
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, {
                "typescript",
                "tsx",
            })
        end,
    },
    { "nvim-lspconfig", opts = {
        servers = {
            ["ts_ls"] = {},
        },
    } },
}

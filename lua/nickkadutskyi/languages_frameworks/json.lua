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
    { "nvim-lspconfig", opts = {
        servers = {
            ["jsonls"] = {},
        },
    } },
}

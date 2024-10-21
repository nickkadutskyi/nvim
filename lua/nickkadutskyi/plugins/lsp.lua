-- mason.nvim -> nvim-lspconfig -> servers via lspconfig
return {
    {
        -- For installing langauge servers
        "williamboman/mason.nvim",
        lazy = false,
        opts = { ui = { border = "rounded" } },
    },
    {
        -- LSP config
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
        },
        config = function()
            -- Have to be run after require("mason.nvim").setup()
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "lua_ls",
                    "ts_ls",
                    "jsonls",
                },
                handlers = {
                    -- Setup lspconfig for each server with default options
                    function(server_name)
                        return require("lspconfig")[server_name].setup({})
                    end,
                },
            })
            vim.diagnostic.config({
                virtual_text = false,
                float = {
                    focusable = false,
                    style = "minimal",
                    border = "rounded",
                    source = true,
                    header = "",
                    prefix = "",
                },
            })
        end,
    },
    {
        "folke/lazydev.nvim",
        ft = "lua", -- only load on lua files
        opts = {
            library = {
                { path = "luvit-meta/library", words = { "vim%.uv" } },
            },
        },
    },
    { "Bilal2453/luvit-meta", lazy = true }, -- optional `vim.uv` typings
}

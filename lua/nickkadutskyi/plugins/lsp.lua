return {
    {
        -- For installing langauge servers
        "williamboman/mason.nvim",
    },
    {
        -- Uses LSP to show current code context—used in status line
        "SmiteshP/nvim-navic",
        dependencies = { "neovim/nvim-lspconfig" },
    },
    {
        -- LSP config
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
            -- Mason—before mason-lspconfig
            require("mason").setup({
                ui = {
                    border = "rounded",
                },
            })

            -- Mason-lspconfig—before manual require("lspconfig")[server_name].setup
            local cmp_lsp = require("cmp_nvim_lsp")
            local capabilities = vim.tbl_deep_extend(
                "force",
                {},
                vim.lsp.protocol.make_client_capabilities(),
                cmp_lsp.default_capabilities()
                -- File watching is disabled by default for neovim.
                -- See: https://github.com/neovim/neovim/pull/22405
                -- { workspace = { didChangeWatchedFiles = { dynamicRegistration = true } } }
            )
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "lua_ls",
                    "ts_ls",
                    "jsonls",
                    "emmet_ls",
                },
                handlers = {
                    -- Setup lspconfig for each server with default options
                    function(server_name)
                        return require("lspconfig")[server_name].setup({
                            capabilities = capabilities,
                        })
                    end,
                    ["lua_ls"] = function()
                        require("lspconfig").lua_ls.setup({
                            capabilities = capabilities,
                            settings = {
                                Lua = {
                                    diagnostics = {
                                        globals = { "vim" },
                                    },
                                },
                            },
                        })
                    end,
                    ["emmet_ls"] = function()
                        require("lspconfig").emmet_ls.setup({
                            filetypes = {
                                "html",
                                "css",
                                "php",
                                "sass",
                                "scss",
                                "vue",
                                "javascript",
                            },
                        })
                    end,
                },
            })

            -- Configure nil_ls (installed in home-manager profile) for nix
            require("lspconfig").nil_ls.setup({
                capabitilies = capabilities,
                settings = {
                    ["nil"] = {
                        testSetting = 42,
                        formatting = {
                            command = { "nixpkgs-fmt" },
                        },
                    },
                },
            })

            -- FIXME is it the best place to do this?
            -- Diagnostics config
            vim.diagnostic.config({
                virtual_text = true,
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

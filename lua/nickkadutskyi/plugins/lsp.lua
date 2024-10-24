return {
    {
        -- For installing langauge servers, formatters, linters, DAPs
        "williamboman/mason.nvim",
        opts = {
            ui = {
                border = "rounded",
            },
        },
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
            -- mason.nvim setup have to be before mason-lspconfig
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function(plugin, _)
            local ensure_ls = {
                "lua_ls",
                "ts_ls",
                "jsonls",
                "emmet_ls",
                "nixd",
            }

            -- language servers to handle with mason
            local mason_ls = {}
            -- language servers to configure with lspconfig
            local lspconfig_ls = {}

            local mason_dir = require("mason.settings").current.install_root_dir
            for _, server_name in ipairs(ensure_ls) do
                local success, config = pcall(require, "lspconfig.configs." .. server_name)
                if success then
                    local cmd = config.default_config.cmd
                    if cmd and type(cmd) == "table" and not vim.tbl_isempty(cmd) then
                        local path = vim.fn.exepath(cmd[1])
                        -- missing from the system or already installed with mason
                        if #path == 0 or string.find(path, mason_dir) ~= nil then
                            table.insert(mason_ls, server_name)
                        else
                            table.insert(lspconfig_ls, server_name)
                        end
                    end
                else
                    vim.notify(
                        string.format(
                            'Config "%s" not found. Ensure it is listed in `neovim/nvim-lspconfig/doc/configs.md`.',
                            server_name
                        ),
                        vim.log.levels.WARN,
                        { title = "Plugin " .. plugin.name .. " config()" }
                    )
                end
            end

            local cmp_lsp = require("cmp_nvim_lsp")
            local capabilities = vim.tbl_deep_extend(
                "force",
                {},
                vim.lsp.protocol.make_client_capabilities(),
                cmp_lsp.default_capabilities()
            )

            local ls_configs = {
                ["lua_ls"] = {
                    settings = {
                        Lua = {
                            diagnostics = {
                                globals = { "vim" },
                            },
                        },
                    },
                },
                ["emmet_ls"] = {
                    filetypes = {
                        "html",
                        "css",
                        "php",
                        "sass",
                        "scss",
                        "vue",
                        "javascript",
                    },
                },
                ["nixd"] = {
                    settings = {
                        ["nixd"] = {
                            formatting = {
                                command = { "nixfmt" },
                            },
                        },
                    },
                },
                ["nil_ls"] = {
                    capabilities = { workspace = { didChangeWatchedFiles = { dynamicRegistration = true } } },
                    settings = {
                        ["nil"] = {
                            testSetting = 42,
                            formatting = {
                                command = { "nixfmt" },
                            },
                        },
                    },
                },
            }

            ---@param server_name string
            ---@param user_config ?lspconfig.Config
            local setup_ls = function(server_name, user_config)
                local conf = vim.tbl_deep_extend(
                    "force",
                    { capabilities = capabilities },
                    ls_configs[server_name] or {},
                    user_config or {}
                )
                require("lspconfig")[server_name].setup(conf)
            end

            -- install language servers with mason and configure
            require("mason-lspconfig").setup({
                ensure_installed = mason_ls,
                handlers = { setup_ls },
            })

            -- configure language servers with lspconfig
            for _, server_name in ipairs(lspconfig_ls) do
                setup_ls(server_name)
            end

            -- Conifgures LspAttach (on_attach) event for all language servers
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("NickKadutskyi", {}),
                callback = function(e)
                    local bufnr = e.buf
                    local client = vim.lsp.get_client_by_id(e.data.client_id)
                    if client ~= nil and client.server_capabilities.documentSymbolProvider then
                        require("nvim-navic").attach(client, bufnr)
                    end

                    local opts = { buffer = e.buf }
                    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
                    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
                    vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
                    vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
                    vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)
                    vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts)
                    vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
                    vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
                    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
                    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
                end,
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

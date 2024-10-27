return {
    {
        -- Rename with incremental search
        "smjonas/inc-rename.nvim",
        config = function()
            require("inc_rename").setup({})
            vim.keymap.set("n", "<leader>vrn", function()
                return ":IncRename " .. vim.fn.expand("<cword>")
            end, { expr = true })
            vim.keymap.set("n", "<S-F6>", function()
                return ":IncRename " .. vim.fn.expand("<cword>")
            end, { expr = true })
            vim.keymap.set("n", "<F18>", function()
                return ":IncRename " .. vim.fn.expand("<cword>")
            end, { expr = true })
        end,
    },
    {
        -- For installing langauge servers, formatters, linters, DAPs
        "williamboman/mason.nvim",
        opts = { ui = { border = "rounded" } },
    },
    {
        -- Uses LSP to show current code context—used in status line
        "SmiteshP/nvim-navic",
        dependencies = { "neovim/nvim-lspconfig" },
    },
    {
        -- LSP config
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        cmd = { "LspInfo", "LspInstall", "LspUninstall" },
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",
            "j-hui/fidget.nvim",
        },
        config = function(plugin, _)
            -- FIXME is this a proper api?
            require("lspconfig.ui.windows").default_options.border = "rounded"

            local ensure_ls = {
                "lua_ls",
                "ts_ls",
                "jsonls",
                "emmet_ls",
                -- "nixd",
                "bashls",
                "nil_ls",

                -- PHP
                "intelephense",
                -- "psalm", -- disabled because it's not working as if ran as cli tool via nvim-lint
            }

            -- language servers to install and configure with mason
            local mason_ls = {}
            -- language servers existing in the system to configure with lspconfig
            local lspconfig_ls = {}
            -- language servers non existing in the system but to try to run via nix run
            local nix_ls = {}

            local mason_dir = require("mason.settings").current.install_root_dir
            local nix_path = vim.fn.exepath("nix")
            -- categorize language servers by how they are configured
            for _, server_name in ipairs(ensure_ls) do
                local success, config = pcall(require, "lspconfig.configs." .. server_name)
                if success then
                    local cmd = config.default_config.cmd
                    if cmd and type(cmd) == "table" and not vim.tbl_isempty(cmd) then
                        local path = vim.fn.exepath(cmd[1])
                        -- missing from the system or already installed with mason
                        if
                            (#path == 0 or string.find(path, mason_dir) ~= nil)
                            and require("mason-lspconfig").get_mappings().lspconfig_to_mason[server_name] ~= nil
                        then
                            mason_ls[server_name] = config.default_config
                        elseif #path ~= 0 then
                            lspconfig_ls[server_name] = config.default_config
                        elseif #nix_path ~= 0 then
                            nix_ls[server_name] = config.default_config
                        else
                            vim.notify(
                                string.format(
                                    "Packag %s is not provided by Mason and nix is not installead. Try to install it manually.",
                                    server_name
                                ),
                                vim.log.levels.WARN,
                                { title = "Plugin " .. plugin.name .. " config()" }
                            )
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

            -- capabilities to provide to lspconfig
            local cmp_lsp = require("cmp_nvim_lsp")
            local capabilities = vim.tbl_deep_extend(
                "force",
                {},
                vim.lsp.protocol.make_client_capabilities(),
                cmp_lsp.default_capabilities()
            )

            -- local runtime_path = vim.split(package.path, ";")
            -- table.insert(runtime_path, "lua/?.lua")
            -- table.insert(runtime_path, "lua/?/init.lua")
            local ls_configs = {
                ["lua_ls"] = {
                    settings = {
                        Lua = {
                            -- Disable telemetry
                            telemetry = { enable = false },
                            -- runtime = {
                            --     version = "LuaJIT",
                            --     path = runtime_path,
                            -- },
                            diagnostics = {
                                globals = { "vim" },
                            },
                            workspace = {
                                checkThirdParty = false,
                                library = {
                                    vim.env.VIMRUNTIME,
                                    "${3rd}/luv/library",
                                },
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
                ["bashls"] = {
                    filetypes = { "sh", "zsh" },
                },
                ["psalm"] = {
                    cmd = { "psalm", "--language-server", "--config=psalm.xml" },
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
                ensure_installed = vim.tbl_keys(mason_ls),
                handlers = { setup_ls },
            })

            -- configure language servers with lspconfig
            for server_name, _ in pairs(lspconfig_ls) do
                setup_ls(server_name)
            end

            -- configure language servers with lspconfig to run via `nix run`
            for server_name, config in pairs(nix_ls) do
                local cmd = config.cmd[1]
                -- confirm store path
                vim.system({ "nix", "path-info", "--json", "nixpkgs#" .. cmd }, { text = true }, function(o)
                    if o.code == 0 then
                        vim.schedule(function()
                            -- configure languge server with lspconfig
                            table.remove(config.cmd, 1)
                            local nix_cmd = vim.list_extend({ "nix", "run", "nixpkgs#" .. cmd, "--" }, config.cmd)
                            setup_ls(server_name, { cmd = nix_cmd })

                            -- try to start language server if filetype matches in case server was configured after opening a file
                            for _, ext in ipairs(config.filetypes) do
                                if string.match(vim.api.nvim_buf_get_name(0), "%." .. ext .. "$") ~= nil then
                                    vim.cmd("LspStart " .. server_name)
                                    break
                                end
                            end
                        end)
                    else
                        vim.notify(
                            string.format("Failed to get path-info fro %s nix package due: %s", cmd, o.stderr),
                            vim.log.levels.ERROR,
                            { title = "Plugin " .. plugin.name .. " config()" }
                        )
                    end
                end)
            end

            -- Conifgures LspAttach (on_attach) event for all language servers
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("nickkadutskyi-lsp-attach", { clear = true }),
                callback = function(event)
                    local bufnr = event.buf

                    local opts = { buffer = event.buf, desc = "LSP: " }
                    -- vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
                    vim.keymap.set("n", "gd", require("fzf-lua").lsp_definitions, opts)
                    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
                    vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
                    vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)
                    vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts)
                    -- vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
                    vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
                    vim.keymap.set("n", "<leader>clf", vim.lsp.buf.format, opts)

                    -- Attach to nvim-navic to show current code context—used in status line
                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    if client ~= nil and client.server_capabilities.documentSymbolProvider then
                        require("nvim-navic").attach(client, bufnr)
                    end

                    -- The following two autocommands are used to highlight references of the
                    -- word under your cursor when your cursor rests there for a little while.
                    -- When you move your cursor, the highlights will be cleared (the second autocommand).
                    if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
                        local hi_augroup = vim.api.nvim_create_augroup("nickkadutskyi-lsp-highlight", { clear = false })
                        vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                            buffer = event.buf,
                            group = hi_augroup,
                            callback = vim.lsp.buf.document_highlight,
                        })

                        vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                            buffer = event.buf,
                            group = hi_augroup,
                            callback = vim.lsp.buf.clear_references,
                        })

                        vim.api.nvim_create_autocmd("LspDetach", {
                            group = vim.api.nvim_create_augroup("nickkadutskyi-lsp-detach", { clear = true }),
                            callback = function(event2)
                                vim.lsp.buf.clear_references()
                                vim.api.nvim_clear_autocmds({
                                    group = "nickkadutskyi-lsp-highlight",
                                    buffer = event2.buf,
                                })
                            end,
                        })
                    end
                end,
            })

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
            vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { noremap = true })
            vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { noremap = true })
            vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, { noremap = true })
            -- nnoremap("<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
            -- nnoremap("<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
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

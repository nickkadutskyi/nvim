-- TODO add ability to jump to a file path in PHP files provided as __DIR__."/path/to/file"
return {
    {
        -- Rename with incremental search
        "smjonas/inc-rename.nvim",
        opts = {
            input_buffer_type = "dressing",
        },
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
                "bashls",
                -- "nixd",
                "nil_ls",

                -- PHP
                "intelephense",
                "phpactor", -- use either phpactor or intelephense to avoid duplcates
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
                            hint = { enable = true },
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
                ["intelephense"] = {
                    init_options = {
                        licenceKey = vim.fn.expand("~/.config/php/intelephense_license.txt"),
                    },
                    intelephense = {
                        telemetry = {
                            enabled = false,
                        },
                        files = {
                            maxSize = 1000000,
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
                    local fzf = require("fzf-lua")

                    vim.keymap.set("n", "gd", function()
                        -- vim.lsp.buf.definition()
                        fzf.lsp_definitions({ winopts = { title = " Choose Definition " } })
                    end, { buffer = event.buf, desc = "LSP: [g]o to [d]efinition" })

                    vim.keymap.set("n", "gD", function()
                        -- vim.lsp.buf.declaration()
                        fzf.lsp_declarations({ winopts = { titne = " Choose Declaration " } })
                    end, { buffer = event.buf, desc = "LSP: [g]o to [D]eclaration" })

                    vim.keymap.set("n", "gr", function()
                        -- vim.lsp.buf.references()
                        fzf.lsp_references({ winopts = { title = " Usages " } })
                    end, { buffer = event.buf, desc = "LSP: [g]o to [r]eferences" })

                    vim.keymap.set("n", "gi", function()
                        -- vim.lsp.buf.implementation()
                        fzf.lsp_implementations({ winopts = { title = " Choose Implementation " } })
                    end, { buffer = event.buf, desc = "LSP: [g]o to [i]mplementations" })

                    vim.keymap.set("n", "<leader>D", function()
                        -- vim.lsp.buf.type_definition()
                        fzf.lsp_type_definitions({ winopts = { title = " Choose Type Definition " } })
                    end, { buffer = event.buf, desc = "LSP: Type [D]efinition" })

                    vim.keymap.set({ "n", "x" }, "<leader>ca", function()
                        -- vim.lsp.buf.code_action()
                        fzf.lsp_code_actions({ winopts = { title = " Context Actions ", title_pos = "left" } })
                    end, { buffer = event.buf, desc = "LSP: [c]ontext [a]ctions" })

                    vim.keymap.set("n", "<leader>gc", function()
                        fzf.lsp_live_workspace_symbols({
                            regex_filter = "Class.*",
                            winopts = { title = " Classes ", title_pos = "left" },
                        })
                    end, { noremap = true, desc = "LSP: [g]o to [c]lass" })

                    vim.keymap.set("n", "<leader>gs", function()
                        fzf.lsp_live_workspace_symbols({
                            winopts = { title = " Symbols ", title_pos = "left" },
                        })
                    end, { desc = "LSP: [g]o to [s]ymbol" })

                    vim.keymap.set("n", "<leader>gas", function()
                        fzf.lsp_live_workspace_symbols({
                            winopts = { title = " All Symbols ", title_pos = "left" },
                        })
                    end, { noremap = true, desc = "LSP: [g]o to [a]ll [s]ymbols" })

                    vim.keymap.set("n", "K", function()
                        vim.lsp.buf.hover()
                    end, { buffer = event.buf, desc = "LSP: [K]eeword lookup/quick documentation" })

                    -- LSP Renaming. <S-F6> on macOS is <F18>
                    vim.keymap.set("n", "<S-F6>", function()
                        -- vim.lsp.buf.rename()
                        return ":IncRename " .. vim.fn.expand("<cword>")
                    end, { expr = true, buffer = event.buf, desc = "LSP: [S-F6/F18] Rename" })
                    vim.keymap.set("n", "<F18>", function()
                        -- vim.lsp.buf.rename()
                        return ":IncRename " .. vim.fn.expand("<cword>")
                    end, { expr = true, buffer = event.buf, desc = "LSP: [F18/S-F6] Rename" })
                    vim.keymap.set("n", "<leader>rn", function()
                        -- vim.lsp.buf.rename()
                        return ":IncRename " .. vim.fn.expand("<cword>")
                    end, { expr = true, buffer = event.buf, desc = "LSP: [r]e[n]ame" })

                    -- vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
                    -- vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
                    vim.keymap.set({ "i", "n" }, "<C-h>", vim.lsp.buf.signature_help, opts)
                    vim.keymap.set("n", "<leader>clf", vim.lsp.buf.format, opts)

                    -- Attach to nvim-navic to show current code context—used in status line
                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    if
                        client ~= nil
                        and client.server_capabilities.documentSymbolProvider
                        and client.name ~= "phpactor"
                        and client.name ~= "psalm"
                    then
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

                    -- The following code creates a keymap to toggle inlay hints in your
                    -- code, if the language server you are using supports them
                    if
                        client
                        and (
                            client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint)
                            or client.server_capabilities.inlayHintProvider
                        )
                    then
                        vim.keymap.set("n", "<leader>th", function()
                            local new_state = not vim.lsp.inlay_hint.is_enabled({
                                bufnr = event.buf,
                            })
                            vim.lsp.inlay_hint.enable(new_state)
                        end, { buffer = event.buf, desc = "[t]oggle inlay [h]ints (LSP)" })
                    end
                end,
            })

            -- Diagnostics config
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
                -- turns off diagnostics signs in gutter
                signs = false,
            })
            vim.keymap.set("n", "]d", vim.diagnostic.goto_next, {
                noremap = true,
                desc = "[n]ext [d]iagnostic (LSP)",
            })
            vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, {
                noremap = true,
                desc = "[p]rev [d]iagnostic (LSP)",
            })
            vim.keymap.set("n", "<leader>sd", vim.diagnostic.open_float, {
                noremap = true,
                desc = "[s]how [d]iagnostic float (LSP)",
            })
            vim.keymap.set("n", "<leader>sq", vim.diagnostic.setloclist, {
                noremap = true,
                desc = "[s]how diagostic [q]uickfix list (LSP)",
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

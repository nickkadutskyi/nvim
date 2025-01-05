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
        opts = { highlight = true, color_correction = "dynamic" },
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
        },
        config = function(plugin, opts)
            local servers = opts.servers or {}

            -- Capabilities to provide to lspconfig
            local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
            local capabilities = vim.tbl_deep_extend(
                "force",
                {},
                vim.lsp.protocol.make_client_capabilities(),
                has_cmp and cmp_nvim_lsp.default_capabilities() or {},
                opts.capabilities or {}
            )

            ---@param server_name string
            ---@param user_config ?lspconfig.Config
            local function setup(server_name, user_config)
                local server_opts = vim.tbl_deep_extend(
                    "force",
                    { capabilities = vim.deepcopy(capabilities) },
                    servers[server_name] or {},
                    user_config or {}
                )

                if server_opts.enabled == false then
                    return
                end

                require("lspconfig")[server_name].setup(server_opts)
            end

            -- get all the servers that are available through mason-lspconfig
            local has_mason_lspconfig, mlsp = pcall(require, "mason-lspconfig")
            local mason_servers = {}
            if has_mason_lspconfig then
                mason_servers = require("mason-lspconfig").get_mappings().lspconfig_to_mason
            end

            local mason_dir = require("mason.settings").current.install_root_dir
            local nix_path = vim.fn.exepath("nix")

            local install_via_mason = {}
            local install_via_nix = {}
            for server_name, server_opts in pairs(servers) do
                -- Checks if server is available in lspconfig
                local has_lspconfig, lspconfig = pcall(require, "lspconfig.configs." .. server_name)
                if has_lspconfig then
                    server_opts = server_opts == true and {} or server_opts
                    if server_opts and server_opts.enabled ~= false then
                        local cmd = lspconfig.default_config.cmd
                        if cmd and type(cmd) == "table" and not vim.tbl_isempty(cmd) then
                            local cmd_path = vim.fn.exepath(cmd[1])
                            if
                                mason_servers[server_name] ~= nil
                                and (string.find(cmd_path, mason_dir) ~= nil or server_opts.mason == true)
                            then
                                install_via_mason[#install_via_mason + 1] = server_name
                            elseif #cmd_path ~= 0 then
                                setup(server_name)
                            elseif #nix_path ~= 0 then
                                install_via_nix[server_name] = lspconfig.default_config
                            end
                        end
                    end
                else
                    vim.notify(
                        string.format("Missing lspconfig: `%s`", server_name),
                        vim.log.levels.WARN,
                        { title = "Plugin " .. plugin.name .. " config()" }
                    )
                end
            end

            -- Installs servers via Mason
            if has_mason_lspconfig then
                mlsp.setup({
                    automatic_installation = false,
                    ensure_installed = install_via_mason,
                    handlers = { setup },
                })
            end

            -- Installs servers via Nix (`nir run nixpkgs#<pkg> --`)
            for server_name, default_config in pairs(install_via_nix) do
                local cmd = servers[server_name].cmd or default_config.cmd
                local nix_pkg = servers[server_name].nix_pkg or cmd[1]
                -- Checks if Nix package is available
                vim.system({ "nix", "path-info", "--json", "nixpkgs#" .. nix_pkg }, { text = true }, function(o)
                    if o.code == 0 then
                        vim.schedule(function()
                            -- configure languge server with lspconfig
                            table.remove(cmd, 1)
                            local nix_cmd = vim.list_extend({
                                "nix",
                                "run",
                                "nixpkgs#" .. nix_pkg,
                                "--",
                            }, cmd)

                            setup(server_name, { cmd = nix_cmd })

                            -- Start language server in case server was
                            -- configured after opening a matching file type
                            for _, ext in ipairs(default_config.filetypes) do
                                if string.match(vim.api.nvim_buf_get_name(0), "%." .. ext .. "$") ~= nil then
                                    vim.cmd("LspStart " .. server_name)
                                    break
                                end
                            end
                        end)
                    else
                        vim.notify(
                            string.format("Did't find `%s` nix package due: %s", nix_pkg, o.stderr),
                            vim.log.levels.WARN,
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
                -- Load luvit types when the `vim.uv` word is found
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                { path = "lazy.nvim", words = { "Lazy" } },
            },
        },
    },
    { "Bilal2453/luvit-meta", lazy = true }, -- optional `vim.uv` typings
}

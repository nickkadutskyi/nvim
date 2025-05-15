-- TODO add ability to jump to a file path in PHP files provided as __DIR__."/path/to/file"

-- Set by `smjonas/inc-rename.nvim` plugin on `init`
local has_inc_rename = false

-- Configures LspAttach (on_attach) event for all language servers to set up keymaps
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("kdtsk-lsp-attach-keymap", { clear = true }),
    callback = function(event)
        local keymap_opts = { buffer = event.buf, desc = "LSP: " }
        local fzf = require("fzf-lua")

        -- Refactor > Rename variable under the cursor
        local rename = function()
            return has_inc_rename and ":IncRename " .. vim.fn.expand("<cword>") or vim.lsp.buf.rename()
        end
        local rename_opts = function(desc)
            return { expr = has_inc_rename, buffer = event.buf, desc = "LSP: " .. desc }
        end
        -- Mimics IntelliJ's refactor > rename
        vim.keymap.set("n", "<S-F6>", rename, rename_opts("[S-F6] Refactor > Rename..."))
        -- <S-F6> on macOS is <F18>
        vim.keymap.set("n", "<F18>", rename, rename_opts("[F18] Refactor > Rename..."))
        -- Overrides the default LSP rename keymap
        vim.keymap.set("n", "grn", rename, rename_opts("[G]o to [R]efactor > Re[n]ame..."))
    end,
})

---@type LazySpec
return {
    { -- Rename with incremental search
        "smjonas/inc-rename.nvim",
        ---@type inc_rename.UserConfig
        opts = {},
        init = function()
            -- Sets to switch to IncRename command in keymap
            has_inc_rename = true
        end,
    },
    { -- Uses LSP to show current code context—used in status line
        "SmiteshP/nvim-navic",
        dependencies = { "neovim/nvim-lspconfig" },
        ---@type Options
        opts = {
            highlight = true,
            color_correction = "dynamic",
            lsp = {
                auto_attach = true,
                preference = {
                    "phpactor", -- TODO: find a way to switch to intelephense
                    "nixd", -- Works better than nil_ls
                },
            },
            format_text = function(text)
                -- This is a workaround for the fact that `nixd` returns
                -- `{anonymous}` as the name of Array kind
                if text == "{anonymous}" then
                    return "{a}"
                end
                return text
            end,
        },
        ---@param opts Options
        config = function(_, opts)
            local navic = require("nvim-navic")

            -- Sets icons from jb.nvim
            opts.icons = vim.tbl_map(function(icon)
                return icon .. " "
            end, require("jb.icons").icons)

            navic.setup(opts)
        end,
    },
    {
        ---@class vim.lsp.ConfigLocal : vim.lsp.Config
        ---@field nix_pkg? string
        ---@field enabled? boolean

        -- LSP config
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        cmd = { "LspInfo", "LspInstall", "LspUninstall" },
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            -- "hrsh7th/cmp-nvim-lsp",
        },
        config = function(plugin, opts)
            local utils = require("nickkadutskyi.utils")
            ---@type table<string, vim.lsp.ConfigLocal>
            local servers = opts.servers or {}

            -- Adds nvim-cmp capabilities for all language servers
            -- local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
            -- vim.lsp.config("*", { capabilities = has_cmp and cmp_nvim_lsp.default_capabilities() or {} })

            -- Gets mason-lspconfig
            local has_mlsp, mlsp = pcall(require, "mason-lspconfig")

            -- Sort server commands by how to handle them
            local commands = {}
            for name, cfg in pairs(servers) do
                local command = cfg.cmd or (vim.lsp.config[name] and vim.lsp.config[name].cmd or nil)
                if cfg.enabled ~= false and command and type(command) ~= "function" then
                    commands[name] = command
                end
            end
            local lsp_to_mason = has_mlsp and mlsp.get_mappings().lspconfig_to_mason or {}
            local via_mason, via_nix, existing, _ = utils.handle_commands(commands, lsp_to_mason)

            -- Sets up existing servers
            for name, _ in pairs(existing) do
                utils.lsp_setup(name, servers[name])
            end

            -- Installs servers via Mason and sets up via handlers
            if has_mlsp then
                mlsp.setup({
                    automatic_installation = false,
                    ensure_installed = via_mason,
                    handlers = {
                        function(name)
                            utils.lsp_setup(name, servers[name])
                        end,
                    },
                })
            end

            -- Check if Nix package exists, install via Nix and set up
            for name, command in pairs(via_nix) do
                local nix_pkg = servers[name].nix_pkg or command
                utils.cmd_via_nix(nix_pkg, command, function(nix_cmd, o)
                    if o.code == 0 then
                        local cmd = servers[name].cmd or vim.lsp.config[name].cmd
                        assert(type(cmd) ~= "function", "`cmd` should not be a function")
                        if cmd and not vim.tbl_isempty(cmd) then
                            table.remove(cmd, 1)
                            servers[name].cmd = vim.list_extend(nix_cmd, cmd)
                            utils.lsp_setup(name, servers[name])
                            -- Helps to trigger FileType event to restart language server
                            for _, ext in ipairs(vim.lsp.config[name].filetypes) do
                                if string.match(vim.api.nvim_buf_get_name(0), "%." .. ext .. "$") ~= nil then
                                    vim.lsp.start(vim.lsp.config[name])
                                    break
                                end
                            end
                        end
                    end
                end)
            end

            -- Configures LspAttach (on_attach) event for all language servers
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("nickkadutskyi-lsp-attach", { clear = true }),
                callback = function(event)
                    local bufnr = event.buf

                    local keymap_opts = { buffer = event.buf, desc = "LSP: " }
                    local fzf = require("fzf-lua")

                    vim.keymap.set("n", "gd", function()
                        -- vim.lsp.buf.definition()
                        fzf.lsp_definitions({ async = true, winopts = { title = " Choose Definition " } })
                    end, { buffer = event.buf, desc = "LSP: [g]o to [d]efinition" })

                    vim.keymap.set("n", "gD", function()
                        -- vim.lsp.buf.declaration()
                        fzf.lsp_declarations({ async = true, winopts = { titne = " Choose Declaration " } })
                    end, { buffer = event.buf, desc = "LSP: [g]o to [D]eclaration" })

                    vim.keymap.set("n", "gr", function()
                        -- vim.lsp.buf.references()
                        fzf.lsp_references({
                            async = true,
                            winopts = { title = " Usages " },
                            ignore_current_line = true,
                            includeDeclaration = false,
                        })
                    end, { buffer = event.buf, desc = "LSP: [g]o to [r]eferences" })

                    vim.keymap.set("n", "gi", function()
                        -- vim.lsp.buf.implementation()
                        fzf.lsp_implementations({ async = true, winopts = { title = " Choose Implementation " } })
                    end, { buffer = event.buf, desc = "LSP: [g]o to [i]mplementations" })

                    vim.keymap.set("n", "<leader>D", function()
                        -- vim.lsp.buf.type_definition()
                        fzf.lsp_typedefs({ async = true, winopts = { title = " Choose Type Definition " } })
                    end, { buffer = event.buf, desc = "LSP: Type [D]efinition" })

                    vim.keymap.set({ "n", "x" }, "<leader>ca", function()
                        -- vim.lsp.buf.code_action()
                        fzf.lsp_code_actions({
                            async = true,
                            winopts = { title = " Context Actions ", title_pos = "left" },
                        })
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
                        vim.lsp.buf.hover({ border = "rounded" })
                    end, { buffer = event.buf, desc = "LSP: [K]eeword lookup/quick documentation" })

                    -- vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
                    -- vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
                    vim.keymap.set({ "i", "n" }, "<C-h>", vim.lsp.buf.signature_help, keymap_opts)
                    vim.keymap.set("n", "<leader>clf", vim.lsp.buf.format, keymap_opts)

                    -- Attach to nvim-navic to show current code context—used in status line
                    local client = vim.lsp.get_client_by_id(event.data.client_id)

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
                update_in_insert = true,
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
                { path = "inc-rename.nvim", words = { "inc_rename" } },
            },
        },
    },
    { "Bilal2453/luvit-meta", lazy = true }, -- optional `vim.uv` typings
    {
        "jmbuhr/otter.nvim",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
        },
        opts = {},
        config = function()
            local otter = require("otter")
            otter.setup({
                lsp = {
                    -- `:h events` that cause the diagnostics to update. Set to:
                    -- { "BufWritePost", "InsertLeave", "TextChanged" } for less performant
                    -- but more instant diagnostic updates
                    -- diagnostic_update_events = { "BufWritePost" },
                    diagnostic_update_events = { "BufWritePost", "InsertLeave", "TextChanged" },
                    -- function to find the root dir where the otter-ls is started
                    root_dir = function(_, bufnr)
                        return vim.fs.root(bufnr or 0, {
                            ".git",
                            "composer.json",
                            "package.json",
                        }) or vim.fn.getcwd(0)
                    end,
                },
                -- options related to the otter buffers
                buffers = {
                    -- if set to true, the filetype of the otterbuffers will be set.
                    -- otherwise only the autocommand of lspconfig that attaches
                    -- the language server will be executed without setting the filetype
                    set_filetype = false,
                    -- write <path>.otter.<embedded language extension> files
                    -- to disk on save of main buffer.
                    -- usefule for some linters that require actual files
                    -- otter files are deleted on quit or main buffer close
                    write_to_disk = true,
                },
                -- list of characters that should be stripped from the beginning and end of the code chunks
                strip_wrapping_quote_characters = { "'", '"', "`" },
                -- remove whitespace from the beginning of the code chunks when writing to the ottter buffers
                -- and calculate it back in when handling lsp requests
                handle_leading_whitespace = true,
                -- mapping of filetypes to extensions for those not already included in otter.tools.extensions
                -- e.g. ["bash"] = "sh"
                extensions = {},
                -- add event listeners for LSP events for debugging
                debug = false,
                verbose = { -- set to false to disable all verbose messages
                    no_code_found = false, -- warn if otter.activate is called, but no injected code was found
                },
            })
            vim.keymap.set("n", "<localleader>ao", function()
                require("otter").activate()
            end, { desc = "LSP: [a]ctivate [o]tter" })
        end,
    },
}

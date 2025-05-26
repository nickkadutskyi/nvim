-- TODO: add ability to jump to a file path in PHP files provided as __DIR__."/path/to/file"

-- Set by `smjonas/inc-rename.nvim` plugin on `init`
local has_inc_rename = false
-- Gets exclude patterns from environment variable `FZFLUA_EXCLUDE`
local fzf_colors_switch = {
    [true] = {
        true,
        ["list-bg"] = { "bg", "WindowBackgroundShowExcluded" },
        ["bg"] = { "bg", "WindowBackgroundShowExcluded" },
        ["pointer"] = { "bg", "WindowBackgroundShowExcluded" },
        ["gutter"] = { "bg", "WindowBackgroundShowExcluded" },
    },
    [false] = true,
}

-- Helper function to resume FZF operation with updated options
local function resume_fzf_with_opts(show_excluded, opts)
    local options = vim.tbl_deep_extend("keep", {
        resume = true,
        fzf_colors = fzf_colors_switch[show_excluded],
    }, opts.__call_opts)
    opts.__call_fn(options)
end

local exclude_patterns = require("kdtsk.utils").parse_exclude_env("FZFLUA_EXCLUDE")
-- Cache the length to avoid recalculating in each iteration
local patterns_len = #exclude_patterns
local function is_excluded(item)
    -- Only check excluded patterns if exclusion is enabled and filename exists
    if item.filename then
        for i = 1, patterns_len do
            if item.filename:match(exclude_patterns[i]) then
                return true
            end
        end
    end

    return false
end
-- Configures LspAttach (on_attach) event for all language servers to set up keymaps
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("kdtsk-lsp-attach-keymap", { clear = true }),
    callback = function(event)
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        local has_fzf, fzf = pcall(require, "fzf-lua")

        -- LSP Rename or Refactor > Rename variable under the cursor
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
        vim.keymap.set("n", "grn", rename, rename_opts("[g]o to [r]efactor > Re[n]ame..."))

        -- LSP Code Action or Context Actions
        vim.keymap.set({ "n", "x" }, "gra", function()
            if has_fzf then
                -- Adds preview of a diff
                fzf.lsp_code_actions({
                    async = true,
                    winopts = { title = " Context Actions ", title_pos = "left" },
                })
            else
                vim.lsp.buf.code_action()
            end
        end, { buffer = event.buf, desc = "LSP: [g]o to [r]efactor > Context [a]ctions" })

        -- LSP References or Usage
        local function usages()
            if has_fzf then
                fzf.lsp_references({
                    async = true,
                    winopts = { title = " Usages " },
                    ignore_current_line = true,
                    includeDeclaration = false,
                })
            else
                vim.lsp.buf.references({ includeDeclaration = false })
            end
        end
        vim.keymap.set("n", "gru", usages, { buffer = event.buf, desc = "LSP: [g]o to [r]efactor > [u]sages" })
        -- Overrides the default LSP references keymap
        vim.keymap.set("n", "grr", usages, { buffer = event.buf, desc = "LSP: [g]o to [r]efactor > [u]sages" })

        -- LSP Implementation
        vim.keymap.set("n", "gri", function()
            if has_fzf then
                fzf.lsp_implementations({ async = true, winopts = { title = " Choose Implementation " } })
            else
                vim.lsp.buf.implementation()
            end
        end, { buffer = event.buf, desc = "LSP: [g]o to [r]efactor > [i]mplementations" })

        -- LSP Definition
        vim.keymap.set("n", "grd", function()
            if has_fzf then
                fzf.lsp_definitions({ async = true, winopts = { title = " Choose Definition " } })
            else
                vim.lsp.buf.definition()
            end
        end, { buffer = event.buf, desc = "LSP: [g]o to [r]efactor > [d]efinitions" })

        -- LSP Declaration
        vim.keymap.set("n", "grD", function()
            if has_fzf then
                fzf.lsp_declarations({ async = true, winopts = { titne = " Choose Declaration " } })
            else
                vim.lsp.buf.declaration()
            end
        end, { buffer = event.buf, desc = "LSP: [g]o to [r]efactor > [D]eclarations" })

        -- LSP Type Definition
        vim.keymap.set("n", "grt", function()
            if has_fzf then
                fzf.lsp_typedefs({ async = true, winopts = { title = " Choose Type Definition " } })
            else
                vim.lsp.buf.type_definition()
            end
        end, { buffer = event.buf, desc = "LSP: [g]o to [r]efactor > Type [D]efinitions" })

        -- Find a Class by name
        local function find_class()
            if has_fzf then
                local show_excluded = false
                fzf.lsp_live_workspace_symbols({
                    regex_filter = function(item, _)
                        if not item.kind:match("Class") then
                            return false
                        end

                        return show_excluded and true or not is_excluded(item)
                    end,
                    winopts = { title = " Classes ", title_pos = "left" },
                    cwd_only = true,
                    actions = {
                        -- Shows/Hides Excluded Classes
                        ["ctrl-e"] = function(_, opts)
                            show_excluded = not show_excluded
                            resume_fzf_with_opts(show_excluded, opts)
                        end,
                    },
                })
            else
                vim.notify(
                    "FZF and similar tools are not present so can't find a class",
                    vim.log.levels.WARN,
                    { title = "Find a Class Keymap" }
                )
            end
        end
        vim.keymap.set("n", "<leader>o", find_class, { buffer = event.buf, desc = "LSP: Find Class by name" })
        vim.keymap.set("n", "<leader>gc", find_class, { buffer = event.buf, desc = "LSP: [g]o to [c]lass" })

        -- LSP Document Symbols or Find a Symbol in the current file
        local function sym_in_doc()
            if has_fzf then
                local file_name = vim.fn.expand("%:t")
                fzf.lsp_document_symbols({
                    cwd_only = true,
                    winopts = { title = " Symbols in " .. file_name .. " ", title_pos = "left" },
                })
            else
                vim.lsp.buf.document_symbol()
            end
        end
        vim.keymap.set("n", "<localleader><A-o>", sym_in_doc, { buffer = event.buf, desc = "LSP: Find Symbol in doc" })
        vim.keymap.set("n", "<localleader>gs", sym_in_doc, { buffer = event.buf, desc = "LSP: [g]o to [s]ymbol" })
        vim.keymap.set("n", "gO", sym_in_doc, { buffer = event.buf, desc = "LSP: [g]o to [s]ymbol" })

        -- LSP Symbols or Find a Symbol
        local function symbol_in_workspace()
            if has_fzf then
                local show_excluded = false
                fzf.lsp_live_workspace_symbols({
                    regex_filter = function(item, _)
                        return show_excluded and true or not is_excluded(item)
                    end,
                    cwd_only = true,
                    winopts = { title = " Symbols ", title_pos = "left" },
                    actions = {
                        -- Shows/Hides Excluded Symbols
                        ["ctrl-e"] = function(_, opts)
                            show_excluded = not show_excluded
                            resume_fzf_with_opts(show_excluded, opts)
                        end,
                    },
                })
            else
                vim.lsp.buf.workspace_symbol()
            end
        end
        vim.keymap.set(
            "n",
            "<leader><A-o>",
            symbol_in_workspace,
            { buffer = event.buf, desc = "LSP: Find a Symbol in current file" }
        )
        vim.keymap.set("n", "<leader>gs", symbol_in_workspace, { buffer = event.buf, desc = "LSP: [g]o to [s]ymbol" })

        -- LSP Hover or Quick Documentation
        vim.keymap.set("n", "K", function()
            vim.lsp.buf.hover({ border = "rounded" })
        end, { buffer = event.buf, desc = "LSP: [K]eeword lookup/quick documentation" })

        -- LSP Signature Help or Parameter Info
        vim.keymap.set({ "i", "n" }, "<C-s>", function()
            vim.lsp.buf.signature_help({ border = "rounded" })
        end, { desc = "LSP: [C-h]elp signature" })

        -- The following two autocommands are used to highlight references of the
        -- word under your cursor when your cursor rests there for a little while.
        -- When you move your cursor, the highlights will be cleared (the second autocommand).
        if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local default_handler = vim.lsp.handlers["textDocument/documentHighlight"]

            -- Looks for line numbers of the highlighted references and stores them in a global variable
            -- For scrollbar marks to show up
            client.handlers["textDocument/documentHighlight"] = function(err, result, ctx, config)
                if result and #result > 0 then
                    local lines_set = {}
                    for _, highlight in ipairs(result) do
                        local range = highlight.range
                        local start_line = range.start.line + 1 -- Convert to 1-based
                        local end_line = range["end"].line + 1
                        for line = start_line, end_line do
                            -- lines_set[line] = true
                            table.insert(lines_set, { line = line, type = "IdentifierUnderCaret", level = 0 })
                        end
                    end
                    -- local lines = vim.tbl_keys(lines_set)
                    -- table.sort(lines)
                    vim.g.highlighted_lines = lines_set
                else
                    vim.g.highlighted_lines = {}
                end
                require("scrollbar.handlers").show()
                require("scrollbar").throttled_render()
                default_handler(err, result, ctx, config)
            end

            local hi_augroup = vim.api.nvim_create_augroup("kdtsk-lsp-highlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                buffer = event.buf,
                group = hi_augroup,
                callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                buffer = event.buf,
                group = hi_augroup,
                callback = function()
                    vim.lsp.buf.clear_references()
                    vim.g.highlighted_lines = {}
                end,
            })

            vim.api.nvim_create_autocmd("LspDetach", {
                group = vim.api.nvim_create_augroup("kdtsk-lsp-detach", { clear = true }),
                callback = function(event2)
                    vim.g.highlighted_lines = {}
                    vim.lsp.buf.clear_references()
                    vim.api.nvim_clear_autocmds({
                        group = "kdtsk-lsp-highlight",
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
            vim.keymap.set("n", "<localleader>th", function()
                local new_state = not vim.lsp.inlay_hint.is_enabled({
                    bufnr = event.buf,
                })
                vim.lsp.inlay_hint.enable(new_state)
            end, { buffer = event.buf, desc = "LSP: [t]oggle inlay [h]ints" })
        end
    end,
})

-- Jump to the next/previous diagnostic
vim.keymap.set("n", "]d", function()
    vim.diagnostic.jump({ count = 1 })
end, { desc = "LSP: [n]ext [d]iagnostic" })
vim.keymap.set("n", "[d", function()
    vim.diagnostic.jump({ count = -1 })
end, { desc = "LSP: [p]rev [d]iagnostic" })

-- Show diagnostic in floating window
vim.keymap.set("n", "<leader>sd", vim.diagnostic.open_float, {
    noremap = true,
    desc = "LSP: [s]how [d]iagnostic float",
})

-- Show diagnostic in quickfix list
vim.keymap.set("n", "<leader>sq", vim.diagnostic.setloclist, {
    noremap = true,
    desc = "LSP: [s]how diagostic [q]uickfix list",
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
        event = "VeryLazy",
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
            end, Utils.icons.kind)

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
            local utils = require("kdtsk.utils")
            ---@type table<string, vim.lsp.ConfigLocal>
            local servers = opts.servers or {}

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
                { path = "nvim-gitstatus", words = { "GitStatus" } },
                { path = "auto-dark-mode.nvim", words = { "AutoDarkMode" } },
                { path = "jb.icons", words = { "jb.icons" } },
            },
        },
    },
    { "Bilal2453/luvit-meta", lazy = true }, -- optional `vim.uv` typings
    {
        "jmbuhr/otter.nvim",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
        },
        -- Due to not using it
        enabled = false,
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

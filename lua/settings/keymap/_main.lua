--- This file name is prefixed with an underscore to make it load before all
--- other keymap files to ensure leader keys are set before loading any plugin
--- or module that might use them in their keymaps.

local utils = require("ide.utils")
local spec = require("ide.spec.builder")
local pack = require("ide.pack")

--- OPTIONS --------------------------------------------------------------------

-- Set leader keys before everything else
-- leader needs to be set before loading any plugin or module
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
-- Delays before mapped sequence to complete
vim.o.timeoutlen = 300

--- AUTOCMDS -------------------------------------------------------------------

utils.run.now_if_arg_or_deferred(function()
    -- Close certain windows with q or escape
    utils.autocmd.create("FileType", {
        group = "ide.keymap.close_with_q",
        pattern = {
            "checkhealth",
            "help",
            "netrw",
            "nvim-pack",
            "nvim-undotree",
            "notify",

            "gitsigns-blame",
            "qf",
            "lazy",
        },
        callback = function(event)
            vim.bo[event.buf].buflisted = false
            utils.run.later(function()
                local opts = { buffer = event.buf, silent = true, desc = "Buffer: [q/Esc] Close" }
                vim.keymap.set("n", "q", function()
                    vim.cmd("close")
                    pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
                end, opts)
                vim.keymap.set("n", "<Esc>", function()
                    vim.cmd("close")
                    pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
                end, opts)
            end)
        end,
    })
end)

--- MAPPINGS -------------------------------------------------------------------

--- FILE

-- Show History...
utils.run.now_if_arg_or_deferred(function()
    vim.keymap.set("n", "<leader>ah", require("undotree").open, {
        desc = "Local: [a]ctivate Show [h]istory..i",
    })
end)

--- EDIT

spec.add({
    "harpoon",
    keys = {
        {
            lhs = "<leader>ab",
            rhs = function()
                require("harpoon"):list():add()
            end,
            desc = "Bookmarks: [a]dd [b]ookmark",
        },
        {
            lhs = "<C-S-P>",
            rhs = function()
                require("harpoon"):list():prev({ ui_nav_wrap = true })
            end,
            desc = "Bookmarks: select previous bookmark in the list.",
        },
        {
            lhs = "<C-S-N>",
            rhs = function()
                require("harpoon"):list():next({ ui_nav_wrap = true })
            end,
            desc = "Bookmarks: select next bookmark in the list.",
        },
        {
            lhs = "<C-1>",
            rhs = function()
                require("harpoon"):list():select(1)
            end,
            desc = "Bookmarks: select [1]st item in the list.",
        },
        {
            lhs = "<C-2>",
            rhs = function()
                require("harpoon"):list():select(2)
            end,
            desc = "Bookmarks: select [2]nd item in the list.",
        },
        {
            lhs = "<C-3>",
            rhs = function()
                require("harpoon"):list():select(3)
            end,
            desc = "Bookmarks: select [3]rd item in the list.",
        },
        {
            lhs = "<C-4>",
            rhs = function()
                require("harpoon"):list():select(4)
            end,
            desc = "Bookmarks: select [4]th item in the list.",
        },
        {
            lhs = "<C-5>",
            rhs = function()
                local harpoon = require("harpoon")
                harpoon:list():select(harpoon:list():length())
            end,
            desc = "Bookmarks: select [last] item in the list.",
        },
    },
})

--- VIEW

utils.run.now_if_arg_or_deferred(function()
    vim.keymap.set("n", "<leader>sd", vim.diagnostic.open_float, {
        desc = "View: [s]how error [d]escription",
    })
    vim.keymap.set("n", "<leader>sqd", vim.diagnostic.setloclist, {
        desc = "View: [s]show [q]uickfix list with error [d]escriptions",
    })
end)

utils.run.on_lsp_attach(function(buf, client)
    -- Quick Documentation
    -- LSP Hover or Quick Documentation
    vim.keymap.set("n", "K", function()
        local border = "none" ---@type string|table
        if pack.is_loaded("jb.nvim") then
            border = require("jb.borders").borders.dialog.default_box or "rounded"
        end
        vim.lsp.buf.hover({ border = border })
    end, { buffer = buf, desc = "LSP: [K]eeword lookup/quick documentation" })

    -- Code View Actions
    -- Parameter Info
    -- LSP Signature Help or Parameter Info
    vim.keymap.set({ "i", "n" }, "<C-s>", function()
        local border = "none" ---@type string|table
        if pack.is_loaded("jb.nvim") then
            border = require("jb.borders").borders.dialog.default_box_header or "rounded"
        end
        vim.lsp.buf.signature_help({ border = border })
    end, { desc = "LSP: [C-h]elp signature" })
end, "keymap.VIEW: failed to set LSP hover and signature help keymaps")

--- Navigate

utils.run.now_if_arg_or_deferred(function()
    vim.keymap.set("n", "]d", function()
        vim.diagnostic.jump({ count = 1 })
    end, { desc = "Navigate: [n]ext [d]iagnostic" })
    vim.keymap.set("n", "<F2>", function()
        vim.diagnostic.jump({ count = 1 })
    end, { desc = "Navigate: Next Highlighted Error" })

    vim.keymap.set("n", "[d", function()
        vim.diagnostic.jump({ count = -1 })
    end, { desc = "Navigate: [p]rev [d]iagnostic" })
    vim.keymap.set("n", "<S-F2>", function()
        vim.diagnostic.jump({ count = -1 })
    end, { desc = "Navigate: Previous Highlighted Error" })

    vim.keymap.set("n", "]p", function()
        require("trouble")._action("next")("document_diagnostics")
    end, { desc = "Problems: next [p]roblem" })
    vim.keymap.set("n", "[p", function()
        require("trouble")._action("prev")("document_diagnostics")
    end, { desc = "Problems: previous [p]roblem" })
end)

--- Goto by Name Actions
-- Go to File...
spec.add({
    "fff.nvim",
    keys = {
        {
            lhs = "<leader>gf",
            rhs = function()
                require("fff").find_files()
            end,
            desc = "Search(fff.nvim): [g]o to [f]ile",
        },
        {
            lhs = "<leader>ff",
            rhs = function()
                require("fff").live_grep({
                    title = "Find in Files",
                    grep = {
                        modes = { "plain", "fuzzy", "regex" },
                    },
                })
            end,
            desc = "Search(fff.nvim): [f]ind in [f]iles",
        },
    },
})

-- Go to File...
spec.add({
    "fzf-lua",
    keys = {
        {
            desc = "Search(fzf-lua): [g]o to [a]ny [f]ile",
            lhs = "<leader>gaf",
            rhs = function()
                require("fzf-lua").files()
            end,
        },
        {
            desc = "Search(fzf-lua): [f]ind in [a]ll [f]iles",
            lhs = "<leader>faf",
            rhs = function()
                require("fzf-lua").live_grep()
            end,
        },
        {
            desc = "[g]o to [b]uffer",
            lhs = "<leader>gb",
            rhs = function()
                require("fzf-lua").buffers()
            end,
        },
    },
})

utils.run.on_lsp_attach(function(buf, client)
    -- Goto Class
    local function find_class()
        if pack.is_loaded("fzf-lua") then
            require("fzf-lua").lsp_live_workspace_symbols({
                regex_filter = function(item, _)
                    if not item.kind:match("Class") then
                        return false
                    end

                    return true
                end,
                winopts = { title = " Classes ", title_pos = "left" },
                cwd_only = true,
            })
        else
            vim.notify(
                "FZF and similar tools are not present so can't find a class",
                vim.log.levels.WARN,
                { title = "Find a Class Keymap" }
            )
        end
    end

    -- vim.keymap.set("n", "<leader>o", find_class, { buffer = event.buf, desc = "LSP: Find Class by name" })
    vim.keymap.set("n", "<leader>gc", find_class, { buffer = buf, desc = "LSP: [g]o to [c]lass" })

    -- LSP Document Symbols or Find a Symbol in the current file
    local function sym_in_doc()
        if pack.is_loaded("fzf-lua") then
            local file_name = vim.fn.expand("%:t")
            require("fzf-lua").lsp_document_symbols({
                cwd_only = true,
                winopts = { title = " Symbols in " .. file_name .. " ", title_pos = "left" },
            })
        else
            vim.lsp.buf.document_symbol()
        end
    end

    vim.keymap.set("n", "<localleader><A-o>", sym_in_doc, { buffer = buf, desc = "LSP: Find Symbol in doc" })
    vim.keymap.set("n", "<localleader>gs", sym_in_doc, { buffer = buf, desc = "LSP: [g]o to [s]ymbol" })
    vim.keymap.set("n", "gO", sym_in_doc, { buffer = buf, desc = "LSP: [g]o to [s]ymbol" })

    -- LSP Symbols or Find a Symbol
    local function symbol_in_workspace()
        if pack.is_loaded("fzf-lua") then
            local show_excluded = false
            require("fzf-lua").lsp_live_workspace_symbols({
                regex_filter = function(item, _)
                    return true
                end,
                cwd_only = true,
                winopts = { title = " Symbols ", title_pos = "left" },
            })
        else
            vim.lsp.buf.workspace_symbol()
        end
    end

    vim.keymap.set(
        "n",
        "<leader><A-o>",
        symbol_in_workspace,
        { buffer = buf, desc = "LSP: Find a Symbol in current file" }
    )
    vim.keymap.set("n", "<leader>gs", symbol_in_workspace, { buffer = buf, desc = "LSP: [g]o to [s]ymbol" })
end, "keymap.GotoByNameActions: failed to set LSP document and workspace symbol keymaps")

-- Goto by Reference Actions
utils.run.on_lsp_attach(function(buf, client)
    -- LSP References or Usage
    local function usages()
        if pack.is_loaded("fzf-lua") then
            require("fzf-lua").lsp_references({
                async = true,
                winopts = { title = " Usages " },
                ignore_current_line = true,
                includeDeclaration = false,
            })
        else
            vim.lsp.buf.references({ includeDeclaration = false })
        end
    end
    vim.keymap.set("n", "gru", usages, { buffer = buf, desc = "Navigate: [g]o to [r]efactor > [u]sages" })
    -- Overrides the default LSP references keymap
    vim.keymap.set("n", "grr", usages, { buffer = buf, desc = "Navigate: [g]o to [r]efactor > [u]sages" })

    -- LSP Implementation
    vim.keymap.set("n", "gri", function()
        if pack.is_loaded("fzf-lua") then
            require("fzf-lua").lsp_implementations({ async = true, winopts = { title = " Choose Implementation " } })
        else
            vim.lsp.buf.implementation()
        end
    end, { buffer = buf, desc = "Navigate: [g]o to [r]efactor > [i]mplementations" })

    -- LSP Definition
    vim.keymap.set("n", "grd", function()
        if pack.is_loaded("fzf-lua") then
            require("fzf-lua").lsp_definitions({ async = true, winopts = { title = " Choose Definition " } })
        else
            vim.lsp.buf.definition()
        end
    end, { buffer = buf, desc = "LSP: [g]o to [r]efactor > [d]efinitions" })

    -- LSP Declaration
    vim.keymap.set("n", "grD", function()
        if pack.is_loaded("fzf-lua") then
            require("fzf-lua").lsp_declarations({ async = true, winopts = { titne = " Choose Declaration " } })
        else
            vim.lsp.buf.declaration()
        end
    end, { buffer = buf, desc = "LSP: [g]o to [r]efactor > [D]eclarations" })

    -- LSP Type Definition
    vim.keymap.set("n", "grt", function()
        if pack.is_loaded("fzf-lua") then
            require("fzf-lua").lsp_typedefs({ async = true, winopts = { title = " Choose Type Definition " } })
        else
            vim.lsp.buf.type_definition()
        end
    end, { buffer = buf, desc = "LSP: [g]o to [r]efactor > Type [D]efinitions" })
end, "keymap.GotoByReferenceActions: failed to set LSP actions")

utils.run.now_if_arg_or_deferred(function()
    vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
    vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
    vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
    vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")
end)

--- CODE

utils.run.now_if_arg_or_deferred(function()
    if vim.lsp.inline_completion.is_enabled() then
        vim.keymap.set("i", "<Tab>", function()
            if not vim.lsp.inline_completion.get() then
                return "<Tab>"
            end
        end, { expr = true, desc = "AI: Insert Inline Proposal" })
        vim.keymap.set({ "i", "n" }, "<A-]>", function()
            vim.lsp.inline_completion.select({ count = 1 })
        end, { expr = true, desc = "AI: Next Inline Proposal" })
        vim.keymap.set({ "i", "n" }, "<A-[>", function()
            vim.lsp.inline_completion.select({ count = -1 })
        end, { expr = true, desc = "AI: Previous Inline Proposal" })
    end
end)

--- Inspect Code
spec.add({
    "nvim-lint",
    keys = {
        {
            desc = "Code: [i]nspect [c]ode",
            lhs = "<leader>ic",
            rhs = function()
                require("lint").try_lint()
            end,
        },
    },
})

--- Code Folding
spec.add({
    "nvim-ufo",
    keys = {
        {
            desc = "Folds: [zR] open all folds",
            lhs = "zR",
            rhs = function()
                require("ufo").openAllFolds()
            end,
        },
        {
            desc = "Folds: [zM] close all folds",
            lhs = "zM",
            rhs = function()
                require("ufo").closeAllFolds()
            end,
        },
        {
            desc = "Folds: [zr] open folds except kinds",
            lhs = "zr",
            rhs = function()
                require("ufo").openFoldsExceptKinds()
            end,
        },
        {
            desc = "Folds: [zm] close folds with",
            lhs = "zm",
            rhs = function()
                require("ufo").closeFoldsWith()
            end,
        },
        {
            desc = "Folds: [zp] peek fold or hover",
            lhs = "zp",
            rhs = function()
                local winid = require("ufo").peekFoldedLinesUnderCursor()
                if not winid then
                    vim.lsp.buf.hover()
                end
            end,
        },
    },
})

-- Comment Action
spec.add({
    "todo-comments.nvim",
    keys = {
        {
            desc = "TODO: Jump to [n]ext [t]odo comment",
            lhs = "]t",
            rhs = function()
                require("todo-comments").jump_next()
            end,
        },
        {
            desc = "TODO: Jump to [p]revious [t]odo comment",
            lhs = "[t",
            rhs = function()
                require("todo-comments").jump_prev()
            end,
        },
    },
})

-- Code Formatting
spec.add({
    "conform.nvim",
    keys = {
        {
            mode = { "n", "v" },
            desc = "Code: [r]eformat [c]ode",
            lhs = "<leader>rc",
            rhs = function()
                require("conform").format()
            end,
        },
    },
})

--- Refactor

-- Rename
utils.run.on_lsp_attach(function(buf, client)
    -- LSP Rename or Refactor > Rename variable under the cursor
    local rename = function()
        return pack.is_loaded("inc-rename.nvim") and ":IncRename " .. vim.fn.expand("<cword>") or vim.lsp.buf.rename()
    end
    local rename_opts = function(desc)
        return { expr = pack.is_loaded("inc-rename.nvim"), buffer = buf, desc = "Refactor: " .. desc }
    end
    -- Mimics IntelliJ's refactor > rename
    vim.keymap.set("n", "<S-F6>", rename, rename_opts("[S-F6] Rename..."))
    -- <S-F6> on macOS is <F18>
    vim.keymap.set("n", "<F18>", rename, rename_opts("[F18] Rename..."))
    -- Overrides the default LSP rename keymap
    vim.keymap.set("n", "grn", rename, rename_opts("[g]o [r]efactor > Re[n]ame..."))
end, "keymap.Refactor: failed to set LSP rename keymaps")

spec.add({
    "99",
    keys = {
        {
            lhs = "<leader>9v",
            rhs = function()
                require("99").visual({})
            end,
            desc = "AI: [9]9 visual selection",
            mode = "v",
        },
        {
            lhs = "<leader>9x",
            rhs = function()
                require("99").stop_all_requests()
            end,
            desc = "AI: [9]9 [x] cancel all requests",
        },
        {
            lhs = "<leader>9s",
            rhs = function()
                require("99").search({})
            end,
            desc = "AI: [9]9 [s]earch",
        },
    },
})

--- FIND

utils.run.now_if_arg_or_deferred(function()
    -- Clear search highlight
    vim.keymap.set("n", "<Esc>", ":noh<CR>", { desc = "Clear search highlight" })
    -- Clear search highlight and delete search history
    vim.keymap.set("n", "<leader>/c", function()
        vim.cmd("nohlsearch") -- Clear search highlight
        vim.fn.setreg("/", "") -- Clear search register
        vim.fn.histdel("/", ".*") -- Clear search history
    end, { desc = "[/] [c]lear search highlight and history" })
    -- Find and Replace currently selected text
    vim.keymap.set(
        "v",
        "<leader>hfr",
        '"hy:%s/<C-r>h/<C-r>h/gci<left><left><left><left>',
        { desc = "Find and replace selected text" }
    )
end)

--- WINDOW

utils.run.now_if_arg_or_deferred(function()
    -- NOTE: Never used it and use <C-w>Arrow while this keymaps reused for quickfix navigation
    -- Keybinds to make split navigation easier.
    -- Use CTRL+<hjkl> to switch between windows
    -- vim.keymap.set({ "n", "i" }, "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
    -- vim.keymap.set({ "n", "i" }, "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
    -- vim.keymap.set({ "n", "i" }, "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
    -- vim.keymap.set({ "n", "i" }, "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

    -- Editor Tabs
    vim.keymap.set({ "n", "i", "v" }, "<M-w>", function()
        if vim.fn.tabpagenr("$") == 1 then
            vim.cmd("bd")
        else
            vim.cmd("tabc")
        end
    end, { desc = "Close current tab (or buffer if last tab)" })
    vim.keymap.set({ "n", "i", "v" }, "<M-t>", function()
        vim.cmd("tabnew")
    end, { desc = "Open new tab" })
end)

--- This file name is prefixed with an underscore to make it load before all
--- other keymap files to ensure leader keys are set before loading any plugin
--- or module that might use them in their keymaps.

local utils = require("ide.utils")
local spec_builder = require("ide.spec.builder")

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
            "nvim-pack",
            "notify",

            "gitsigns-blame",
            "qf",
            "lazy",
        },
        callback = function(event)
            vim.bo[event.buf].buflisted = false
            utils.run.later(function()
                local opts = { buffer = event.buf, silent = true, desc = "Buffer: [q/Esc] Close" }
                -- TODO: check if it's the last window in the tabpage, and if so, close the tabpage instead
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

--- EDIT

spec_builder.add({
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

--- CODE

utils.run.now_if_arg_or_deferred(function()
    -- TODO: provide an ability to accept partial inline completion (by word or line)
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
end)

--- Code Folding
spec_builder.add({
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
spec_builder.add({
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

-- TODO: come up with better keymap for this
spec_builder.add({
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
    -- Keybinds to make split navigation easier.
    -- Use CTRL+<hjkl> to switch between windows
    vim.keymap.set({ "n", "i" }, "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
    vim.keymap.set({ "n", "i" }, "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
    vim.keymap.set({ "n", "i" }, "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
    vim.keymap.set({ "n", "i" }, "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

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

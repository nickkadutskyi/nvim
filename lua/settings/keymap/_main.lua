--- This file name is prefixed with an underscore to make it load before all
--- other keymap files to ensure leader keys are set before loading any plugin
--- or module that might use them in their keymaps.

local utils = require("ide.utils")

--- OPTIONS --------------------------------------------------------------------

-- Set leader keys before everything else
-- leader needs to be set before loading any plugin or module
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
-- Delays before mapped sequence to complete
vim.o.timeoutlen = 300

--- AUTOCMDS -------------------------------------------------------------------

utils.run.now_if_args(function()
    -- Close certain windows with q or escape
    utils.autocmd.create("FileType", {
        group = "ide.keymap.close_with_q",
        pattern = {
            "PlenaryTestPopup",
            "checkhealth",
            "dbout",
            "gitsigns-blame",
            "grug-far",
            "help",
            "lspinfo",
            "neotest-output",
            "neotest-output-panel",
            "neotest-summary",
            "notify",
            "qf",
            "spectre_panel",
            "startuptime",
            "tsplayground",
            "lazy",
            "nvim-pack",
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

utils.run.now_if_args(function()
    --- FIND
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

    --- WINDOW
    -- Keybinds to make split navigation easier.
    -- Use CTRL+<hjkl> to switch between windows
    vim.keymap.set({ "n", "i" }, "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
    vim.keymap.set({ "n", "i" }, "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
    vim.keymap.set({ "n", "i" }, "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
    vim.keymap.set({ "n", "i" }, "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })
end)

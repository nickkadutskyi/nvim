-- Delay before mapped sequence to complete
vim.opt.timeoutlen = 500

-- KEYMAP (key bindings also defined in plugins' config functions)

-- Control what happens to the register when deleting, changing, and pasting
-- When deleting string don't add it to the register
vim.keymap.set("n", "<leader>d", '"_d', { desc = "Delete without yanking" })
vim.keymap.set("v", "<leader>d", '"_d', { desc = "Delete without yanking" })
vim.keymap.set("n", "<leader>D", '"_D', { desc = "Delete until end without yanking" })
vim.keymap.set("v", "<leader>D", '"_D', { desc = "Delete until end without yanking" })
-- When changing string don't add it to the register
vim.keymap.set("n", "<leader>c", '"_c', { desc = "Change without yanking" })
vim.keymap.set("v", "<leader>c", '"_c', { desc = "Change without yanking" })
vim.keymap.set("n", "<leader>C", '"_C', { desc = "Change until end without yanking" })
vim.keymap.set("v", "<leader>C", '"_C', { desc = "Change until end without yanking" })
-- When deleting a character don't add it to the register
vim.keymap.set("n", "<leader>x", '"_x', { desc = "Delete character without yanking" })
vim.keymap.set("v", "<leader>x", '"_x', { desc = "Delete character without yanking" })

-- When pasting over a selection don't add selection to the register
vim.keymap.set("x", "<leader>p", '"_dP', { desc = "Paste over selection without yanking" })
-- Yank and paste to system clipboard
-- Yank to system clipboard
vim.keymap.set("n", "<leader>y", '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set("v", "<leader>y", '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>Y", '"+Y', { desc = "Yank line to system clipboard" })
-- Paste from system clipboard
-- vim.keymap.set('n', '<leader>p', '"+p', { desc = 'Paste from system clipboard' }) -- commented out as in original
vim.keymap.set("n", "<leader>P", '"+P', { desc = "Paste before from system clipboard" })
vim.keymap.set("x", "<leader>P", '"+P', { desc = "Paste before from system clipboard" })

-- Move cursor down half a page
-- vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Move down half page and center' })
-- Move cursor half a page down and centers cursor unless it's end of file then scroll 3 lines past the end of file
vim.keymap.set("n", "<C-d>", function()
    if vim.fn.line("$") - vim.fn.line(".") - vim.fn.line("w$") + vim.fn.line("w0") > 0 then
        return "<C-d>zz"
    else
        return "<C-d>zb<C-e><C-e><C-e>"
    end
end, { expr = true, desc = "Smart half page down" })
-- Move cursor up half page and center window
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Move up half page and center" })
-- Go to next search occurrence and center window
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result and center" })
-- Go to previous search occurrence and center window
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result and center" })

-- Clear search highlight
vim.keymap.set("n", "<Esc>", ":noh<CR>", { desc = "Clear search highlight" })
-- Clear search highlight and delete search history
vim.keymap.set("n", "<leader>/c", function()
    vim.cmd("nohlsearch") -- Clear search highlight
    vim.fn.setreg("/", "") -- Clear search register
    vim.fn.histdel("/", ".*") -- Clear search history
end, { desc = "Clear search highlight and history" })

-- Code Editing
-- Move highlighted Code
vim.keymap.set("n", "<S-Down>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<S-Up>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("i", "<S-Down>", "<Esc>:m .+1<CR>==gi", { desc = "Move line down" })
vim.keymap.set("i", "<S-Up>", "<Esc>:m .-2<CR>==gi", { desc = "Move line up" })
vim.keymap.set("v", "<S-Down>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<S-Up>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Find and Replace currently selected text
vim.keymap.set(
    "v",
    "<leader>hfr",
    '"hy:%s/<C-r>h/<C-r>h/gci<left><left><left><left>',
    { desc = "Find and replace selected text" }
)

-- Keybinds to make split navigation easier.
-- Use CTRL+<hjkl> to switch between windows
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Lazy.nvim modules
return {
    {
        -- Keymap search and documentation
        "folke/which-key.nvim",
        event = "VeryLazy",
        keys = {
            {
                "<leader>?",
                function()
                    require("which-key").show({ global = false })
                end,
                desc = "Buffer Local Keymaps (which-key)",
            },
        },
        config = function()
            local wk = require("which-key")
            wk.setup({
                sort = { "desc", "group", "alphanum", "local", "order", "mod" },
                keys = {
                    scroll_down = "<c-n>", -- binding to scroll down inside the popup
                    scroll_up = "<c-p>", -- binding to scroll up inside the popup
                },
            })
            -- Groups: [Leader|None] > [Action] > [Modifier|None] > [Object]
            wk.add({
                {
                    "<leader>",
                    group = "Leader",

                    {
                        "<leader>a",
                        group = "[a]ctivate",

                        { "<leader>av", group = "[v]ersion control" },
                    },
                    { "<leader>c", group = "[c]hoose" },
                    { "<leader>e", group = "[e]xpose" },
                    { "<leader>f", group = "[f]ind" },
                    { "<leader>g", group = "[g]o to" },
                    { "<leader>r", group = "[r]eformat" },
                    {
                        "<leader>s",
                        group = "[s]how",

                        { "<leader>sr", group = "[r]ecent" },
                    },
                    { "<leader>t", group = "[t]oggle" },
                },
                { "]", group = "[n]ext" },
                { "[", group = "[p]rev" },
                { "<A-Up>", desc = "TS: Init Incremental Selection | Increment Node" },
                { "<A-s>", desc = "TS: Increment Scope" },
                { "<A-Down>", desc = "TS: Decrement Node" },
                { "<Tab>", desc = "AI Assist: Accept suggestion" },
                { "<A-Tab>", desc = "AI Assist: Accept word suggestion" },
                { "<S-Tab>", desc = "AI Assist: Accept line suggestion" },
                { "<A-]>", desc = "AI Assist: Next suggestion" },
                { "<A-[>", desc = "AI Assist: Previous suggestion" },
                { "<C-]>", desc = "AI Assist: Dismiss suggestion" },
            })
            -- Keymaps
            vim.keymap.set("n", "<leader>?n", function()
                wk.show({ mode = "n", global = false })
            end, { silent = true, desc = "Buffer Local Keymaps (which-key)" })
            vim.keymap.set("n", "<leader>?a", function()
                wk.show({})
            end, { silent = true, desc = "Buffer Local Keymaps (which-key)" })
        end,
    },
}

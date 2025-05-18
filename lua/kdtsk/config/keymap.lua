-- Delay before mapped sequence to complete
vim.opt.timeoutlen = 300

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
vim.keymap.set({ "n", "i" }, "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set({ "n", "i" }, "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set({ "n", "i" }, "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set({ "n", "i" }, "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Lazy.nvim
vim.keymap.set("n", "<leader>al", function()
    require("lazy").show()
end, { silent = true, desc = "Plugins: [a]ctivate plugins tool window (Lazy.nvim)" })

---@type LazySpec
return {
    {
        -- Keymap search and documentation
        "folke/which-key.nvim",
        event = "VimEnter",
        enabled = true,
        ---@type wk.Opts
        opts = {
            spec = {
                -- Provides Keymap Groups: [Leader|LocalLeader|None] > [Action] > [Modifier|None] > [Object]
                {
                    "<Leader>",
                    group = "Leader",

                    { "<leader>?", group = "[?]which-key help" },
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
                        icon = { icon = "", hl = "WhichKeyValue" },

                        { "<leader>sr", group = "[r]ecent" },
                    },
                    { "<leader>t", group = "[t]oggle" },
                },
                {
                    "<LocalLeader>",
                    group = "LocalLeader",
                    {
                        "<localleader>a",
                        group = "[a]ctivate",
                        mode = { "v", "n" },

                        { "<localleader>?", group = "[?]which-key help" },
                        { "<localleader>av", group = "[v]ersion control" },
                    },
                    { "<localleader>e", group = "[e]dit", mode = { "v", "n" } },
                },
                { "]", group = "[n]ext" },
                { "[", group = "[p]rev" },
                -- TODO moves to a file related to Treesitter
                -- Treesitter
                { "<A-Up>", desc = "TS: Init Incremental Selection | Increment Node" },
                { "<A-s>", desc = "TS: Increment Scope" },
                { "<A-Down>", desc = "TS: Decrement Node" },
            },
            delay = 200,
            icons = {
                rules = {
                    { pattern = "^plugins:.*", icon = "", color = "grey" },
                    { pattern = "^vcs:.*", icon = "", color = "grey" },
                    { pattern = "%[v%]ersion control", icon = "", color = "grey" },
                    { pattern = "^terminal:.*", icon = "", color = "grey" },
                    { pattern = "^run:.*", icon = "󰑮", color = "grey" },
                    { pattern = "^ai:.*", icon = "󱙺", color = "grey" },
                    { pattern = "^project:.*", icon = "", color = "grey" },
                },
                mappings = vim.g.nerd_font_is_present,
                keys = vim.g.nerd_font_is_present and {} or {
                    Up = "<Up> ",
                    Down = "<Down> ",
                    Left = "<Left> ",
                    Right = "<Right> ",
                    C = "<C-…> ",
                    M = "<M-…> ",
                    D = "<D-…> ",
                    S = "<S-…> ",
                    CR = "<CR> ",
                    Esc = "<Esc> ",
                    ScrollWheelDown = "<ScrollWheelDown> ",
                    ScrollWheelUp = "<ScrollWheelUp> ",
                    NL = "<NL> ",
                    BS = "<BS> ",
                    Space = "<Space> ",
                    Tab = "<Tab> ",
                    F1 = "<F1>",
                    F2 = "<F2>",
                    F3 = "<F3>",
                    F4 = "<F4>",
                    F5 = "<F5>",
                    F6 = "<F6>",
                    F7 = "<F7>",
                    F8 = "<F8>",
                    F9 = "<F9>",
                    F10 = "<F10>",
                    F11 = "<F11>",
                    F12 = "<F12>",
                },
            },
            sort = { "desc", "group", "alphanum", "local", "order", "mod" },
            keys = {
                scroll_down = "<c-n>", -- binding to scroll down inside the popup
                scroll_up = "<c-p>", -- binding to scroll up inside the popup
            },
            plugins = {
                marks = false, -- shows a list of your marks on ' and `
                registers = false, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
                -- the presets plugin, adds help for a bunch of default keybindings in Neovim
                -- No actual key bindings are created
                presets = {
                    operators = true, -- adds help for operators like d, y, ...
                    motions = true, -- adds help for motions
                    text_objects = true, -- help for text objects triggered after entering an operator
                    windows = true, -- default bindings on <c-w>
                    nav = true, -- misc bindings to work with windows
                    z = true, -- bindings for folds, spelling and others prefixed with z
                    g = true, -- bindings for prefixed with g
                },
            },
        },
        config = function(_, opts)
            local wk = require("which-key")
            wk.setup(opts)

            -- Keymap
            vim.keymap.set("n", "<leader>?n", function()
                wk.show({ mode = "n", global = true })
            end, { silent = true, desc = "Global keymap for normal mode" })
            vim.keymap.set("n", "<leader>?i", function()
                wk.show({ mode = "i", global = true })
            end, { silent = true, desc = "Global keymaps for insert mode" })
            vim.keymap.set("n", "<localleader>?n", function()
                wk.show({ mode = "n", global = false })
            end, { silent = true, desc = "Buffer keymap for normal mode" })
            vim.keymap.set("n", "<localleader>?i", function()
                wk.show({ mode = "i", global = false })
            end, { silent = true, desc = "Buffer keymaps for insert mode" })
        end,
    },
}

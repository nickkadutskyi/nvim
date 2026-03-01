--- OPTIONS --------------------------------------------------------------------

-- leader needs to be set before loading any plugin or module
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
-- Delays before mapped sequence to complete
vim.o.timeoutlen = 300

--- MAPPINGS -------------------------------------------------------------------

-- Treesitter Inspect builtin
vim.keymap.set("n", "<leader>ip", "<cmd>Inspect<CR>", {
    desc = "TS: [i]spect Treesitter [p]osition",
})
vim.keymap.set("n", "<leader>it", "<cmd>InspectTree<CR>", {
    desc = "TS: [i]spect Treesitter [t]ree",
})

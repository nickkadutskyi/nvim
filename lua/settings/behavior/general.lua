--- OPTIONS --------------------------------------------------------------------

-- Allows to execute project local .nvim.lua, .nvimrc, .exrc files
vim.opt.exrc = true

--- Local History
local vim_dir = os.getenv("HOME") .. "/.vim"
vim.o.undodir = vim_dir .. "/undo"
vim.o.directory = vim_dir .. "/swap"
vim.o.undofile = true
vim.o.swapfile = true
vim.o.updatetime = 250
vim.o.backup = false

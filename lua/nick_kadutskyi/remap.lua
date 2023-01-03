local nnoremap = require("nick_kadutskyi.keymap").nnoremap
-- local vnoremap = require("nick_kadutskyi.keymap").vnoremap
local builtin = require('telescope.builtin')

-- General
--
-- Go back to Netrw
nnoremap("<leader>pv", "<cmd>Ex<CR>")


-- Telescope
--
-- Search project files (Go to File)
nnoremap('<leader>gf', builtin.find_files, {})
-- Live grep in project files (Find in Path)
nnoremap('<leader>fp', builtin.live_grep, {})
-- Search git files (git ls-files)
nnoremap('<C-p>', builtin.git_files, {})
-- Lists open buffers in current neovim instance
nnoremap('<leader>gb', builtin.buffers, {})
-- File browser action
nnoremap('<leader>fb', ":Telescope file_browser<CR>")


-- Neoformat
--
-- Reformat Code
nnoremap('<leader>cf', ':Neoformat<CR>')

-- Undotree
--
-- UndotreeToggle
nnoremap('<leader>u', ':UndotreeToggle<CR>')


-- Vim Fuigitive
--
-- Git Satus
nnoremap('<leader>gs', ':Git<CR>')


-- Trouble
-- 
-- Open Problems window
nnoremap('<leader>xx', ':TroubleToggle<CR>')
-- Quick Fix
nnoremap('<leader>xq', ':TroubleToggle quickfix<CR>')


-- Nvim Tree
--
-- Toggle and focus
nnoremap('<leader>z1', function ()
  -- local api = require"nvim-tree.api"
  -- api.tree.toggle(false, false)
  vim.cmd('NvimTreeFocus')
end)


-- Code Editing
--
-- Move hightlighted code
-- vnoremap( "<S-Up>", ":m '<-2<CR>gv=gv")
-- vnoremap( "<S-Down>", ":m '>+1<CR>gv=gv")

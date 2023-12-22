local fzf = require("fzf-lua")
local nnoremap = require("nick_kadutskyi.keymap").nnoremap
-- local vnoremap = require("nick_kadutskyi.keymap").vnoremap
-- local builtin = require("telescope.builtin")

-- Browser Neotree and Netrw
--
-- Go back to Netrw
nnoremap("<leader>pv", "<cmd>Ex<CR><CR>")

-- Telescope
--
-- Search project files (Go to File) → Switched to Fzf-lua
-- nnoremap("<leader>gf", builtin.find_files, {})
-- Live grep in project files (Find in Path) → Switched to Fzf-lua
-- nnoremap("<leader>fp", builtin.live_grep, {})
-- Search git files (git ls-files)
-- nnoremap("<C-p>", builtin.git_files, {})
-- Lists open buffers in current neovim instance → Switched to Fzf-lua
-- nnoremap("<leader>gb", builtin.buffers, {})
-- File browser action
-- nnoremap("<leader>fb", ":Telescope file_browser<CR>")

-- Fzf-lua
--
nnoremap("<leader>gf", function()
	fzf.files()
end, {})
nnoremap("<leader>gc", fzf.lsp_live_workspace_symbols, {})
nnoremap("<leader>gs", function()
	fzf.lsp_live_workspace_symbols({
		-- prompt = "Sho",
    -- lsp_query = "sho"
    -- lsp_params = {}
	})
end, {})
nnoremap("<leader>fp", fzf.live_grep, {})
nnoremap("<leader>gb", fzf.buffers, {})

-- Neoformat
--
-- Reformat Code
-- nnoremap('<leader>cf', ':Neoformat<CR>')
nnoremap("<leader>cf", ":Format<CR>")

-- Undotree
--
-- UndotreeToggle
nnoremap("<leader>u", ":UndotreeToggle<CR>")

-- Vim Fuigitive
--
-- Git Satus
-- nnoremap("<leader>gs", ":Git<CR>")

-- Trouble
--
-- Open Problems window
nnoremap("<leader>xx", ":TroubleToggle<CR>")
-- Quick Fix
nnoremap("<leader>xq", ":TroubleToggle quickfix<CR>")

-- Code Editing
--
-- Move hightlighted code
-- vnoremap( "<S-Up>", ":m '<-2<CR>gv=gv")
-- vnoremap( "<S-Down>", ":m '>+1<CR>gv=gv")

-- Treesitter Inspect builtin
nnoremap("<leader>ti", ":Inspect<CR>")
nnoremap("<leader>tti", ":InspectTree<CR>")

-- Exit search mode
nnoremap("<leader>/h", ":noh<CR>")
nnoremap("<leader>/c", ':noh | let@/ = "" | call histdel("/", ".*") | wshada!<CR>')

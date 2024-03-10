local fzf = require("fzf-lua")
local nnoremap = require("nick_kadutskyi.keymap").nnoremap
local conform = require("conform")
-- Fzf-lua
--
-- Go to file
nnoremap("<leader>gf", fzf.files, {})
-- Go to Class
nnoremap("<leader>gc", fzf.lsp_live_workspace_symbols, {})
-- Go to Symbol (same as class)
nnoremap("<leader>gs", fzf.lsp_live_workspace_symbols, {})
-- Find in path
nnoremap("<leader>fp", fzf.live_grep, {})
-- Go to buffer (Similar to Switcher in Intellij)
nnoremap("<leader>gb", fzf.buffers, {})

-- Neoformat
--
-- Reformat Code
-- nnoremap('<leader>cf', ':Neoformat<CR>')
nnoremap("<leader>cf", function()
	conform.format({ lsp_fallback = true })
end)
nnoremap("<leader>clf", vim.lsp.buf.format)

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

-- Obsidian
vim.keymap.set("n", "fl", function()
	if require("obsidian").util.cursor_on_markdown_link() then
		return "<cmd>ObsidianFollowLink<CR>"
	else
		return "fl"
	end
end, { noremap = false, expr = true })

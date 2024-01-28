vim.opt.cmdheight = 0
vim.opt.swapfile = false
vim.opt.backup = false
-- disabled for windows support
-- vim.opt.undodir = os.getenv( "HOME" ) .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.colorcolumn = "80,100,120"

-- make zsh files recognized as sh for bash-ls & treesitter because there is no parser for zsh
vim.filetype.add({
	extension = {
		zsh = "sh",
		sh = "sh", -- force sh-files with zsh-shebang to still get sh as filetype
	},
	filename = {
		[".zshrc"] = "sh",
		[".zshenv"] = "sh",
		[".zpath"] = "sh",
		[".zprofile"] = "sh",
	},
})

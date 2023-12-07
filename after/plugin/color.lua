local auto_dark_mode = require("auto-dark-mode")
local augroup = vim.api.nvim_create_augroup -- Create/get autocommand group
local autocmd = vim.api.nvim_create_autocmd -- Create autocommand

-- JB configs
--
-- Enables intalics
vim.g.jb_enable_italics = 1
-- Sets default light style
vim.g.jb_style = "light"
-- Adjusts capture group styles
augroup("JBHiglights", { clear = true })
autocmd("ColorScheme", {
	group = "JBHiglights",
	pattern = "*",
	callback = function()
		vim.api.nvim_set_hl(0, "@variable.php", { link = "JBConstant" })
		vim.api.nvim_set_hl(0, "@namespace.php", { link = "Normal" })
		vim.api.nvim_set_hl(0, "@type.php", { link = "Normal" })
		vim.api.nvim_set_hl(0, "@type.definition.php", { link = "Normal" })
		vim.api.nvim_set_hl(0, "@tag.attribute", { link = "Normal" })
		vim.api.nvim_set_hl(0, "@constructor.php", { link = "Normal" })
		vim.api.nvim_set_hl(0, "@tag.php", { link = "JBKeyword" })
	end,
})
-- Read hardcoded style from bash var
local theme = os.getenv("theme")

if theme == nil then
	-- Only start auto dark mode switcher if theme env var wasn't used
	auto_dark_mode.setup({
		update_interval = 1000,
		set_dark_mode = function()
			vim.api.nvim_set_var("jb_style", "dark")
			vim.cmd("colorscheme jb")
		end,
		set_light_mode = function()
			vim.api.nvim_set_var("jb_style", "light")
			vim.cmd("colorscheme jb")
		end,
	})
else
	-- If theme var provided enforce colorscheme style and don't auto change
	if theme == "light" or theme == "l" then
		vim.g.jb_style = "light"
	elseif theme == "dark" or theme == "d" then
		vim.g.jb_style = "dark"
	elseif theme == "mid" or theme == "m" then
		vim.g.jb_style = "mid"
	end
end

-- enables jb theme after configuration
vim.cmd("colorscheme jb")

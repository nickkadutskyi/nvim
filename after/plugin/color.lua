local auto_dark_mode = require("auto-dark-mode")

-- JB configs
--
-- Enables intalics
vim.g.jb_enable_italics = 1
-- Sets default light style
vim.g.jb_style = "light"

-- Read hardcoded style from bash var
local theme = os.getenv("theme")

if theme == nil then
	-- Only start auto dark mode switcher if theme env var wasn't used
	auto_dark_mode.setup({
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
	-- enables colorscheme after config
	vim.cmd("colorscheme jb")
end

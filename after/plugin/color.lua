-- Rose Pine configs
-- require('rose-pine').setup({
-- 	--- @usage 'main' | 'moon'
-- 	dark_variant = 'main',
-- 	bold_vert_split = false,
-- 	dim_nc_background = false,
-- 	disable_background = false,
-- 	disable_float_background = false,
-- 	disable_italics = false,
--
-- 	--- @usage string hex value or named color from rosepinetheme.com/palette
-- 	groups = {
-- 		background = 'base',
-- 		panel = 'surface',
-- 		border = 'highlight_med',
-- 		comment = 'muted',
-- 		link = 'iris',
-- 		punctuation = 'subtle',
--
-- 		error = 'love',
-- 		hint = 'iris',
-- 		info = 'foam',
-- 		warn = 'gold',
--
-- 		headings = {
-- 			h1 = 'iris',
-- 			h2 = 'foam',
-- 			h3 = 'rose',
-- 			h4 = 'gold',
-- 			h5 = 'pine',
-- 			h6 = 'foam',
-- 		}
-- 		-- or set all headings at once
-- 		-- headings = 'subtle'
-- 	},
--
-- 	-- Change specific vim highlight groups
-- 	highlight_groups = {
-- 		ColorColumn = { bg = 'highlight_med' }
-- 	}
-- })

-- JB configs
-- Enables intalics
vim.g.jb_enable_italics = 1

local augroup = vim.api.nvim_create_augroup -- Create/get autocommand group
local autocmd = vim.api.nvim_create_autocmd -- Create autocommand

augroup("JBHiglights", { clear = true })
autocmd("ColorScheme", {
	group = "JBHiglights",
	pattern = "*",
	callback = function()
    -- Sets treesitter queries because they doesn't work for PHP
    -- require("vim.treesitter.query").set("php", "highlights", '"?>" @tag')
    -- require("vim.treesitter.query").set("php", "highlights", '"?>" @tag')
		vim.api.nvim_set_hl(0, "@variable.php", { link = "JBConstant" })
		vim.api.nvim_set_hl(0, "@namespace.php", { link = "Normal" })
		vim.api.nvim_set_hl(0, "@type.php", { link = "Normal" })
		vim.api.nvim_set_hl(0, "@type.definition.php", { link = "Normal" })
		vim.api.nvim_set_hl(0, "@tag.attribute", { link = "Normal" })
		vim.api.nvim_set_hl(0, "@constructor.php", { link = "Normal" })
		vim.api.nvim_set_hl(0, "@tag.php", { link = "JBKeyword" })

    -- vim.api.nvim_command("redraw")
    -- print(require("vim.treesitter.query").get('php',"@tag"))
		-- vim.api.nvim_set_hl(0, "@tag", { link = "JBConstant" })

		-- vim.api.nvim_set_hl(0, "@tag.php", { link = "JBKeyword" })
		-- vim.api.nvim_set_hl(0, "@type.php", { link = "JBType" })
		-- vim.api.nvim_set_hl(0, "phpFunction", { link = "JBFunction" })
	end,
})

-- set colorscheme after options
-- vim.cmd('colorscheme rose-pine')

if os.getenv("theme") == "light" or os.getenv("theme") == "l" then
	vim.o.background = "light"
	vim.g.jb_style = "light"
else
	vim.o.background = "dark"
	vim.g.jb_style = "dark"
end

-- enables jb theme
vim.cmd("colorscheme jb")

-- auto dark mode switch

local auto_dark_mode = require("auto-dark-mode")

auto_dark_mode.setup({
	update_interval = 1000,
	set_dark_mode = function()
		vim.api.nvim_set_option("background", "dark")
		-- sets jb theme to dark and reenables it
		vim.api.nvim_set_var("jb_style", "dark")
		vim.cmd("colorscheme jb")
	end,
	set_light_mode = function()
		vim.api.nvim_set_option("background", "light")
		-- sets jb theme to light and reenables it
		vim.api.nvim_set_var("jb_style", "light")
		vim.cmd("colorscheme jb")
	end,
})
auto_dark_mode.init()

-- Rose Pine configs
require('rose-pine').setup({
	--- @usage 'main' | 'moon'
	dark_variant = 'main',
	bold_vert_split = false,
	dim_nc_background = false,
	disable_background = false,
	disable_float_background = false,
	disable_italics = false,

	--- @usage string hex value or named color from rosepinetheme.com/palette
	groups = {
		background = 'base',
		panel = 'surface',
		border = 'highlight_med',
		comment = 'muted',
		link = 'iris',
		punctuation = 'subtle',

		error = 'love',
		hint = 'iris',
		info = 'foam',
		warn = 'gold',

		headings = {
			h1 = 'iris',
			h2 = 'foam',
			h3 = 'rose',
			h4 = 'gold',
			h5 = 'pine',
			h6 = 'foam',
		}
		-- or set all headings at once
		-- headings = 'subtle'
	},

	-- Change specific vim highlight groups
	highlight_groups = {
		ColorColumn = { bg = 'highlight_med' }
	}
})

-- JB configs
-- Enables intalics
vim.g.jb_enable_italics = 1



-- set colorscheme after options
-- vim.cmd('colorscheme rose-pine')

if os.getenv('theme') == 'light' or os.getenv('theme') == 'l' then
  vim.o.background = 'light'
  vim.g.jb_style = 'light'
else
  vim.o.background = 'dark'
  vim.g.jb_style = 'dark'
end

-- enables jb theme
vim.cmd('colorscheme jb')

-- auto dark mode switch

local auto_dark_mode = require('auto-dark-mode')

auto_dark_mode.setup({
	update_interval = 1000,
	set_dark_mode = function()
		vim.api.nvim_set_option('background', 'dark')
    -- sets jb theme to dark and reenables it
    vim.api.nvim_set_var('jb_style', 'dark')
    vim.cmd('colorscheme jb')
		-- vim.cmd('colorscheme gruvbox')
	end,
	set_light_mode = function()
		vim.api.nvim_set_option('background', 'light')
    -- sets jb theme to light and reenables it
    vim.api.nvim_set_var('jb_style', 'light')
    vim.cmd('colorscheme jb')
		-- vim.cmd('colorscheme gruvbox')
	end,
})
auto_dark_mode.init()

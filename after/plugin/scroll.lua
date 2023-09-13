-- Cinnamon Scroll
require("cinnamon").setup({
	-- KEYMAPS:
	default_keymaps = true, -- Create default keymaps.
	extra_keymaps = true, -- Create extra keymaps.
	extended_keymaps = false, -- Create extended keymaps.
	override_keymaps = false, -- The plugin keymaps will override any existing keymaps.

	-- OPTIONS:
	always_scroll = false, -- Scroll the cursor even when the window hasn't scrolled.
	centered = true, -- Keep cursor centered in window when using window scrolling.
	disabled = false, -- Disables the plugin.
	default_delay = 3, -- The default delay (in ms) between each line when scrolling.
	hide_cursor = false, -- Hide the cursor while scrolling. Requires enabling termguicolors!
	horizontal_scroll = true, -- Enable smooth horizontal scrolling when view shifts left or right.
	max_length = -1, -- Maximum length (in ms) of a command. The line delay will be
	-- re-calculated. Setting to -1 will disable this option.
	scroll_limit = 150, -- Max number of lines moved before scrolling is skipped. Setting
	-- to -1 will disable this option.
})

-- Neoscroll
-- require("neoscroll").setup({
-- -- All these keys will be mapped to their corresponding default scrolling animation
-- mappings = { "<C-u>", "<C-d>", "<C-b>", "<C-f>", "<C-y>", "<C-e>", "zt", "zz", "zb" },
-- 	hide_cursor = true, -- Hide cursor while scrolling
-- 	stop_eof = true, -- Stop at <EOF> when scrolling downwards
-- 	respect_scrolloff = false, -- Stop scrolling when the cursor reaches the scrolloff margin of the file
-- 	cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
-- 	easing_function = nil, -- Default easing function
-- 	pre_hook = nil, -- Function to run before the scrolling animation starts
-- 	post_hook = nil, -- Function to run after the scrolling animation ends
-- 	performance_mode = false, -- Disable "Performance Mode" on all buffers.
-- })

-- local t = {}
-- -- Syntax: t[keys] = {function, {function arguments}}
-- t["<C-u>"] = { "scroll", { "-vim.wo.scroll", "true", "250" } }
-- t["<C-d>"] = { "scroll", { "vim.wo.scroll", "true", "250" } }
-- t["<C-b>"] = { "scroll", { "-vim.api.nvim_win_get_height(0)", "true", "450" } }
-- t["<C-f>"] = { "scroll", { "vim.api.nvim_win_get_height(0)", "true", "450" } }
-- t["<C-y>"] = { "scroll", { "-0.10", "false", "100" } }
-- t["<C-e>"] = { "scroll", { "0.10", "false", "100" } }
-- t["zt"] = { "zt", { "250" } }
-- t["zz"] = { "zz", { "250" } }
-- t["zb"] = { "zb", { "250" } }

-- require("neoscroll.config").set_mappings(t)

-- Neotree
require("neo-tree").setup({
	close_if_last_window = true,
	event_handlers = {

		{
			event = "file_opened",
			handler = function(file_path)
				-- auto close
				-- vimc.cmd("Neotree close")
				-- OR
				require("neo-tree.command").execute({ action = "close" })
			end,
		},
	},
	window = {
		position = "float",
		popup = { -- settings that apply to float position only
			size = { width = "65" },
			-- position = { row  =20, col = 10},
			position = "0%",
			col = 10,
			row = 10,
			border = {
				text = {
					-- top = " Project ",
				},
				style = "rounded",
        highlight = "Normal",
			},
		},
		title = "Project",
	},
	popup_border_style = "rounded",
})

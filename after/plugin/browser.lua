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
			position = "0%",
		},
	},
	popup_border_style = "rounded",
})

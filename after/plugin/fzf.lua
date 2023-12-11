require("fzf-lua").setup({
	"telescope", -- Sets telescope profile for look and feel
	-- fzf_colors = {
	-- ["fg"] = { "fg", "Normal" },
	-- },
	fzf_colors = {
		["fg"] = { "fg", "CursorLine" },
		["bg"] = { "bg", "Normal" },
		["hl"] = { "fg", "Comment" },
		["fg+"] = { "fg", "Normal" },
		["bg+"] = { "bg", "CursorLine" },
		["hl+"] = { "fg", "Statement" },
		["info"] = { "fg", "PreProc" },
		["prompt"] = { "fg", "Conditional" },
		["pointer"] = { "fg", "Exception" },
		["marker"] = { "fg", "Keyword" },
		["spinner"] = { "fg", "Label" },
		["header"] = { "fg", "Comment" },
		["gutter"] = { "bg", "EndOfBuffer" },
	},
	previewers = {
		builtin = {
			extensions = {
				-- ["svg", "png", "jpg"] = {"chafa"}
				["svg"] = { "chafa" },
				["png"] = { "chafa", "<file>" },
				["jpg"] = { "chafa" },
			},
		},
	},
})

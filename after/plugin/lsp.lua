local lsp = require("lsp-zero")

lsp.preset("recommended")

lsp.set_preferences({
	sign_icons = {
		error = "E",
		warn = "W",
		hint = "H",
		info = "I",
	},
})

-- lsp.nvim_workspace()

-- Needed for nvim-navic
lsp.on_attach(function(client, bufnr)
	lsp.default_keymaps({ buffer = bufnr })

	if client.server_capabilities.documentSymbolProvider then
		require("nvim-navic").attach(client, bufnr)
	end
end)

lsp.setup()

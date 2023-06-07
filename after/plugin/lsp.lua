local lsp = require("lsp-zero")

lsp.preset("recommended")

lsp.ensure_installed({
	"vimls",
	"bashls",
	"jsonls",
	"lemminx",
	"yamlls",
	"intelephense",
})

lsp.set_preferences({
	sign_icons = {
		error = "E",
		warn = "W",
		hint = "H",
		info = "I",
	},
})

lsp.configure("intelephense", {
	licenseKey = "00WS74ZNX2TKTI8",
})

lsp.nvim_workspace()
lsp.setup()

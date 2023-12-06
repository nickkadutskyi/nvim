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

lsp.configure("intelephense", {
	licenseKey = "00WS74ZNX2TKTI8",
})

-- lsp.nvim_workspace()

-- Needed for nvim-navic
lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})

  if client.server_capabilities.documentSymbolProvider then
    require('nvim-navic').attach(client, bufnr)
  end
end)

-- Updates statusline with Navic info
vim.o.statusline = "%<%f %h%m%r %{%v:lua.require'nvim-navic'.get_location()%} %=%-14.(%l,%c%V%) %P"

lsp.setup()


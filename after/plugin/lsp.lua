require('lspconfig.ui.windows').default_options.border = 'rounded'

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

-- LSP Formatters
lsp.format_mapping("gq", {
  format_opts = {
    async = true,
    timeout_ms = 10000,
  },
  servers     = {
    ["prettierd"] = { "javascript", "typescript" },
    ["rust_analyzer"] = { "rust" },
  },
})

lsp.setup()

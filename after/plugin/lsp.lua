local lsp = require('lsp-zero')

lsp.preset('recommended')

lsp.ensure_installed({
  'sumneko_lua',
  'vimls',
  'bashls',
  'jsonls',
  'lemminx',
  'yamlls'
})

lsp.set_preferences({
  sign_icons = {
    error = 'E',
    warn = 'W',
    hint = 'H',
    info = 'I'
  }
})

lsp.nvim_workspace()
lsp.setup()

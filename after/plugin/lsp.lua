local lsp = require('lsp-zero')

lsp.preset('recommended')

lsp.ensure_installed({
  'tsserver',
  'eslint',
  'sumneko_lua',
  'rust_analyzer',
  'html',
  'cssls',
  'phpactor',
  'emmet_ls',
  'intelephense',
  'vimls',
  'bashls',
  'psalm',
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

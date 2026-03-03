local spec_builder = require("ide.spec.builder")
local g = require("ide.utils.str").prepend_fn("https://github.com/")

--- Define all plugins with their src here. Feature files patch via name only.
spec_builder.add({
    --- A notification manager with a nice UI
    { src = g("rcarriga/nvim-notify"), version = "ab98fecfe" },
    --- Treesitter for syntax highlighting, folding, etc.
    {
        --- Requires: tree-sitter, tar, curl, c compiler
        src = g("nvim-treesitter/nvim-treesitter"),
        data = {
            build = function()
                vim.cmd("TSUpdate")
            end,
            ---@param opts ide.Opts.Treesitter
            after = function(_, opts)
                require("ide.utils").treesitter.ensure_installed(opts.ensure_installed)
                require("ide.utils").treesitter.create_auto_start_autocmd(opts)
            end,
        },
    },
    --- My color scheme that recreates IntelliJeJ's look and feel in Neovim
    {
        src = g("nickkadutskyi/jb.nvim"),
        data = { dev = true, deferred = false },
    },
    --- Helps with go to definitons and references in lua
    {
        src = g("folke/lazydev.nvim"),
        data = {
            ft = "lua",
            after = function(_, opts)
                require("lazydev").setup(opts)
            end,
        },
    },
    --- Provides a popup with possible keymaps of the command you started typing
    {
        --- Loaded on keymap trigger in lua/settings/keymap/plugins.lua
        src = g("folke/which-key.nvim"),
        data = {
            after = function(_, opts)
                require("which-key").setup(opts)
            end,
        },
    },
})

local spec_builder = require("ide.spec.builder")
local utils = require("ide.utils")
local g = utils.str.prepend_fn("https://github.com/")

--- Define all plugins with their src here. Feature files patch via name only.
spec_builder.add({
    --- A notification manager with a nice UI
    { src = g("rcarriga/nvim-notify"), version = "ab98fecfe" },
    --- Treesitter for syntax highlighting, folding, etc.
    {
        --- Requires: tree-sitter, tar, curl, c compiler
        src = g("nvim-treesitter/nvim-treesitter"),
        data = {
            opts_extend = { "ensure_installed" },
            build = function()
                vim.cmd("TSUpdate")
            end,
            ---@param opts ide.Opts.Treesitter
            after = function(_, opts)
                local uts = require("ide.utils").treesitter
                uts.ensure_installed(opts.ensure_installed)
                uts.create_auto_start_autocmd(opts)
                uts.setup_custom_parsers(opts.custom_parsers)
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
    --- Compatibility layer for using nvim-cmp sources on blink.cmp
    --- Required by 99 when using blink as the completion source
    {
        src = g("saghen/blink.compat"),
        data = {
            event = "IdeDeferred",
            after = function()
                require("blink.compat").setup({})
            end,
        },
    },
    --- AI Assistant for code generation, refactoring, etc.
    {
        src = g("ThePrimeagen/99"),
        data = {
            event = "IdeDeferred",
            ---@param opts _99.Options
            after = function(_, opts)
                local _99 = require("99")
                opts.logger = {
                    level = _99.DEBUG,
                    path = "/tmp/" .. vim.fs.basename(vim.uv.cwd()) .. ".99.debug",
                    print_on_error = true,
                }
                _99.setup(opts)
            end,
        },
    },
})

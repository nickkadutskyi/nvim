local spec_builder = require("ide.spec.builder")
local g = require("ide.utils.str").prepend_fn("https://github.com/")

--- Define all plugins with their src here. Feature files patch via name only.
spec_builder.add({
    { src = g("rcarriga/nvim-notify"), version = "ab98fecfe" },
    { --- Requires: tree-sitter, tar, curl, c compiler
        src = g("nvim-treesitter/nvim-treesitter"),
        data = {
            build = function()
                vim.cmd("TSUpdate")
            end,
        },
    },
    { src = g("nickkadutskyi/jb.nvim"), data = { dev = true } },
    --- Helps with go to definitons and references in lua
    { src = g("folke/lazydev.nvim"), data = { ft = "lua" } },
    { src = g("folke/which-key.nvim") },
})

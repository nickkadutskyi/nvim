local utils = require("ide.utils")
local spec_builder = require("ide.spec.builder")

--- AUTOCMDS -------------------------------------------------------------------

utils.run.now_if_arg_or_deferred(function()
    utils.autocmd.create("TermOpen", {
        group = "settings.no-spell-in-term",
        desc = "Disable spell checking in terminal buffers",
        callback = function()
            vim.opt_local.spell = false
        end,
    })
    utils.autocmd.create("FileType", {
        group = "settings.wrap-spell",
        desc = "Wrap and check for spell in text filetypes",
        pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
        callback = function()
            vim.opt_local.wrap = true
            vim.opt_local.spell = true
        end,
    })
end)

--- OPTIONS --------------------------------------------------------------------

-- vim.opt.spell = true
vim.opt.spelllang = { "en_us", "en", "ru", "uk" }
vim.opt.spellfile = os.getenv("HOME") .. "/.config/nvim_spell/en.utf-8.add"

--- PLUGINS --------------------------------------------------------------------
spec_builder.add({
    "which-key.nvim",
    opts = {
        spelling = {
            -- enabling this will show WhichKey when pressing z= to select spelling suggestions
            enabled = true,
            -- how many suggestions should be shown in the list?
            suggestions = 10,
        },
    },
})

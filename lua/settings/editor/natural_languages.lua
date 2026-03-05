local utils = require("ide.utils")

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
-- TODO: WhichKey for spelling suggestions

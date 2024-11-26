---Config
vim.opt.spell = true
vim.opt.spelllang = "en,en_us"
vim.api.nvim_create_autocmd({ "TermOpen" }, {
    group = vim.api.nvim_create_augroup("nickkadutskyi-term-spell-check", { clear = true }),
    callback = function()
        vim.opt_local.spell = false
    end,
})

---Lazy modules
return {
    { -- Provides spelling suggestions popup instead of the default list
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            spelling = {
                enabled = true, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
                suggestions = 20, -- how many suggestions should be shown in the list?
            },
        },
    },
}

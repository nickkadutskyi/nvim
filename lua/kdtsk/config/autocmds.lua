-- Disable spell checking in terminal buffers
vim.api.nvim_create_autocmd({ "TermOpen" }, {
    group = vim.api.nvim_create_augroup("kdtsk-term-spell-check", { clear = true }),
    callback = function()
        vim.opt_local.spell = false
    end,
})

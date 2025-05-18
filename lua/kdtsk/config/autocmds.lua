-- Appearance and Behavior

-- - Appearance
-- -- UI Options
--- Sets Tmux window name to the current buffer name when in tmux session
if os.getenv("TMUX") then
    vim.api.nvim_create_autocmd("BufEnter", {
        group = vim.api.nvim_create_augroup("kdtsk-tmux-window-name", { clear = true }),
        callback = function()
            -- FIXME: cache titlestring somewhere to avoid re-evaluating it
            -- TODO: should I make async system call?
            -- Rename tmux window using the evaluated titlestring
            vim.fn.system(string.format('tmux rename-window "%s"', Utils.ui.titlestring()))
        end,
    })
end

-- Disable spell checking in terminal buffers
vim.api.nvim_create_autocmd({ "TermOpen" }, {
    group = vim.api.nvim_create_augroup("kdtsk-term-spell-check", { clear = true }),
    callback = function()
        vim.opt_local.spell = false
    end,
})

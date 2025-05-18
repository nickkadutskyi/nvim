local vim_dir = vim.fn.expand("$HOME/.vim")
local swap_dir = vim_dir .. "/swap"
local undo_dir = vim_dir .. "/undonvim"
-- Check if vim_dir is not in runtimepath
if vim.fn.stridx(vim.o.runtimepath, vim_dir) == -1 then
    -- Add vim_dir to runtimepath
    vim.o.runtimepath = vim.o.runtimepath .. "," .. vim_dir
end
-- Keep undo history and swap across sessions by storing it in a file
if vim.fn.has("persistent_undo") == 1 then
    if vim.fn.isdirectory(swap_dir) == 0 then
        vim.fn.mkdir(swap_dir, "p", "0o700")
    end
    if vim.fn.isdirectory(undo_dir) == 0 then
        vim.fn.mkdir(undo_dir, "p", "0o700")
    end
    -- Set the directories
    vim.o.undodir = undo_dir
    vim.o.directory = swap_dir
    -- Enable undofile and swapfile
    vim.o.undofile = true
    vim.o.swapfile = true
    -- Delay before writing a swap file to disk
    vim.opt.updatetime = 250
end
-- Disables backup files
vim.opt.backup = false

return {}

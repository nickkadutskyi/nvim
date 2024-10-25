-- Define as much as possible in .vimrc to share configs with vim and ideavim
local vimrc = vim.fn.expand("~/.vimrc")
if vim.fn.filereadable(vimrc) then
    vim.cmd.source(vimrc)
end

-- Load plugins
require("nickkadutskyi.lazy_init")

-- If opened a dir set it as current dir to help narrow down fzf scope
if vim.fn.isdirectory(vim.fn.expand("%")) == 1 then
    vim.api.nvim_set_current_dir(vim.fn.expand("%"))
elseif vim.fn.filereadable(vim.fn.expand("%")) == 1 then
    vim.api.nvim_set_current_dir(vim.fn.expand("%:p:h"))
end

-- NEOVIM SPECIFIC SETTINGS

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- Remove cmd line to allow more space
vim.opt.cmdheight = 0

-- Treesitter Inspect builtin
vim.keymap.set("n", "<leader>ti", ":Inspect<CR>", { noremap = true })
vim.keymap.set("n", "<leader>tti", ":InspectTree<CR>", { noremap = true })

-- highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("NickKadutskyi", { clear = false }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

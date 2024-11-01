-- Define as much as possible in .vimrc to share configs with vim and ideavim
local vimrc = vim.fn.expand("~/.vimrc")
if vim.fn.filereadable(vimrc) then
    vim.cmd.source(vimrc)
else
    -- TODO provide lua configs from other sources
end

-- If opened a dir set it as current dir to help narrow down fzf scope
if vim.fn.isdirectory(vim.fn.expand("%")) == 1 then
    vim.api.nvim_set_current_dir(vim.fn.expand("%"))
elseif vim.fn.filereadable(vim.fn.expand("%")) == 1 then
    vim.api.nvim_set_current_dir(vim.fn.expand("%:p:h"))
end

vim.filetype.add({
    extension = {
        neon = "yaml",
        --   bar = function(path, bufnr)
        --     if some_condition() then
        --       return 'barscript', function(bufnr)
        --         -- Set a buffer variable
        --         vim.b[bufnr].barscript_version = 2
        --       end
        --     end
        --     return 'bar'
        --   end,
    },
    filename = {
        [".jsbeautifyrc"] = "json",
        --   ['.foorc'] = 'toml',
        --   ['/etc/foo/config'] = 'toml',
    },
    -- pattern = {
    --   ['.*/etc/foo/.*'] = 'fooscript',
    --   -- Using an optional priority
    --   ['.*/etc/foo/.*%.conf'] = { 'dosini', { priority = 10 } },
    --   -- A pattern containing an environment variable
    --   ['${XDG_CONFIG_HOME}/foo/git'] = 'git',
    --   ['.*README.(%a+)'] = function(path, bufnr, ext)
    --     if ext == 'md' then
    --       return 'markdown'
    --     elseif ext == 'rst' then
    --       return 'rst'
    --     end
    --   end,
    -- },
})

-- Load plugins
require("nickkadutskyi.lazy_init")

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
    group = vim.api.nvim_create_augroup("nickkadutskyi-highlight-yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

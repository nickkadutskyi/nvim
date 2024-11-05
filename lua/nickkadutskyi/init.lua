-- Define as much as possible in .vimrc to share configs with vim and ideavim
local vimrc = vim.fn.expand("~/.vimrc")
if vim.fn.filereadable(vimrc) then
    vim.cmd.source(vimrc)
else
    -- TODO provide lua configs from other sources
end

-- If opened a dir set it as current dir to help narrow down fzf scope
-- Later project.nvim will adjust cwd
if vim.fn.isdirectory(vim.fn.expand("%")) == 1 then
    vim.api.nvim_set_current_dir(vim.fn.expand("%"))
elseif vim.fn.filereadable(vim.fn.expand("%")) == 1 then
    vim.api.nvim_set_current_dir(vim.fn.expand("%:p:h"))
end

vim.filetype.add({
    extension = {
        neon = "yaml",
    },
    filename = {
        [".jsbeautifyrc"] = "json",
    },
    pattern = {
        [".*"] = {
            function(path, bufnr)
                local content = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] or ""
                -- AppleScript written in JavaScript
                if vim.regex([[^#!/usr/bin/osascript -l JavaScript]]):match_str(content) ~= nil then
                    return "javascript"
                end
            end,
            { priority = -math.huge },
        },
    },
})

-- Load plugins
require("nickkadutskyi.lazy_init")

-- NEOVIM SPECIFIC SETTINGS

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- Remove cmd line to allow more space
vim.opt.cmdheight = 0

-- Treesitter Inspect builtin
vim.keymap.set("n", "<leader>si", ":Inspect<CR>", {
    noremap = true,
    desc = "[s]how treesitter [i]nspection",
})
vim.keymap.set("n", "<leader>sti", ":InspectTree<CR>", {
    noremap = true,
    desc = "[s]how treesitter [t]ree [i]nspection",
})

-- highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("nickkadutskyi-highlight-yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- Enfore readonly for vendor and node_modules
vim.api.nvim_create_autocmd("BufRead", {
    group = vim.api.nvim_create_augroup("nickkadutskyi-readonly-dirs", { clear = true }),
    pattern = {
        "*/vendor/*",
        "*/node_modules/*",
    },
    callback = function()
        vim.opt_local.readonly = true
        vim.opt_local.modifiable = false
    end,
})

-- Terminal mappings

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

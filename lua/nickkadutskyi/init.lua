-- Settings
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- If opened a dir set it as current dir to help narrow down fzf scope
-- Later project.nvim will adjust cwd
if vim.fn.isdirectory(vim.fn.expand("%")) == 1 then
    vim.api.nvim_set_current_dir(vim.fn.expand("%"))
elseif vim.fn.filereadable(vim.fn.expand("%")) == 1 then
    vim.api.nvim_set_current_dir(vim.fn.expand("%:p:h"))
end

-- Bootstrap lazy.nvim for loading all the plugins and modules
require("nickkadutskyi.lazy_init")
-- Loads config modules via Lazy.nvim
require("lazy").setup({
    spec = {
        { import = "nickkadutskyi.appearance_behavior" },
        { import = "nickkadutskyi.keymap" },
        { import = "nickkadutskyi.editor" },
        { import = "nickkadutskyi.version_control" },
        { import = "nickkadutskyi.languages_frameworks" },
        { import = "nickkadutskyi.tools" },
        { import = "nickkadutskyi.other" },
    },
    change_detection = { enable = true, notify = false },
    ui = { border = "rounded", title = " Plugin Manager " },
    dev = { path = "~/Developer/PE/0027", patterns = { "nickkadutskyi" }, fallback = true },
})


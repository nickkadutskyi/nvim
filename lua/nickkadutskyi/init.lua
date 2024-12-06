-- leader needs to be set before loading any plugin or module
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.g.nerd_font_is_present = true

-- If opened a dir then set it as the cwd and if opened a file then set the
-- file's parent dir as the cwd to narrow down the scope for fzf
-- Later ahmedkhalf/project.nvim will adjust cwd based on .git or LSP
local curr_path = vim.fn.resolve(vim.fn.expand("%"))
if vim.fn.isdirectory(vim.fn.expand("%")) == 1 then
    vim.api.nvim_set_current_dir(curr_path)
elseif vim.fn.filereadable(vim.fn.expand("%")) == 1 then
    vim.api.nvim_set_current_dir(vim.fn.fnamemodify(curr_path, ":p:h"))
end

-- Bootstraps lazy.nvim for loading all the plugins and modules
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- Loads config modules via Lazy.nvim
require("lazy").setup({
    spec = {
        -- Customizes IDE (non-editor-specific parts) appearance and behavior
        { import = "nickkadutskyi.appearance_behavior" },
        -- Provides generic (non-plugin-specific) Keymap
        { import = "nickkadutskyi.keymap" },
        -- Configures all editor specific parts (completion, code style and quality, color scheme, etc.)
        { import = "nickkadutskyi.editor" },
        -- Everything related to version control systems (e.g. Git)
        { import = "nickkadutskyi.version_control" },
        -- Provides language-specific settings (Lazy modules provide `opts` but configured in other areas)
        { import = "nickkadutskyi.languages_frameworks" },
        -- Other tools (terminal, task runner, AI assistant, etc.)
        { import = "nickkadutskyi.tools" },
        -- Uncategorized
        { import = "nickkadutskyi.other" },
    },
    change_detection = { enable = true, notify = false },
    install = { colorscheme = { "jb" } },
    ui = { border = "rounded", title = " Plugins ", size = { width = 0.5 } },
    dev = { path = "~/Developer/PE/0027", patterns = { "nickkadutskyi" }, fallback = true },
})

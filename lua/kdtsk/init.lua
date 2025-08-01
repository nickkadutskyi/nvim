--- Example: { php = { php_cs_fixer = { use_for = { style = true } } } }
---@alias kdtsk.Settings table<string, table<string, {
---    use_for: table<kdtsk.tools.Purpose, boolean>, -- use the tool for the given purpose
---    lsp_settings?: table, -- provide settings for LSP
---  }>>
---@type kdtsk.Settings
vim.g.settings = nil
---@type boolean
vim.g.settings_loaded = false

_G.Utils = require("kdtsk.utils")

-- Loads all the options
require("kdtsk.config.options")

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

-- Handle settings
vim.api.nvim_create_autocmd("VimEnter", {
    group = vim.api.nvim_create_augroup("kdtsk-settings", { clear = true }),
    callback = function()
        -- Set vim.g.settings and call SettingsLoaded autocmd in .nvim.lua
        -- to have project specific settings otherwise it's set to defaults
        if vim.g.settings == nil then
            vim.g.settings = {}
        end
        vim.api.nvim_command("doautocmd User SettingsLoaded")
    end,
})

-- If not opening a file or a directory then load autocmds later
local later_autocmds = vim.fn.argc(-1) == 0
if not later_autocmds then
    require("kdtsk.config.autocmds")
end

Utils.on_later(function()
    -- Loads modules after all plugins are loaded
    if later_autocmds then
        require("kdtsk.config.autocmds")
    end
    -- Provides generic (non-plugin-specific) Keymap
    require("kdtsk.config.keymap")

    -- TODO do root detection here or maybe before this autocmd?

    -- Starts LSP logs rotation
    Utils.lsp.rotate_lsp_logs()
    vim.fn.timer_start(3600000, Utils.lsp.rotate_lsp_logs, { ["repeat"] = -1 })
end, vim.api.nvim_create_augroup("kdtsk-lazyvim", { clear = true }))

-- Loads Settings modules via Lazy.nvim
require("lazy").setup({
    spec = {
        -- Customizes IDE (non-editor-specific parts) appearance and behavior
        { import = "kdtsk.settings.appearance_behavior" },
        { import = "kdtsk.settings.keymap" },
        -- Configures all editor specific parts (completion, code style and quality, color scheme, etc.)
        { import = "kdtsk.settings.editor" },
        -- Everything related to version control systems (e.g. Git)
        { import = "kdtsk.settings.version_control" },
        -- Provides language-specific settings (Lazy modules provide `opts` but configured in other areas)
        { import = "kdtsk.settings.languages_frameworks" },
        -- Other tools (terminal, task runner, AI assistant, etc.)
        { import = "kdtsk.settings.tools" },
        -- Uncategorized
        { import = "kdtsk.settings.other" },
    },
    change_detection = { enable = true, notify = false },
    install = { colorscheme = { "jb" } },
    ui = { border = "rounded", title = " Plugins ", size = { width = 0.6 } },
    dev = { path = "~/Documents", patterns = { "nickkadutskyi" }, fallback = true },
    -- profiling = {
    --     -- Enables extra stats on the debug tab related to the loader cache.
    --     -- Additionally gathers stats about all package.loaders
    --     loader = true,
    --     -- Track each new require in the Lazy profiling tab
    --     require = true,
    -- },
})

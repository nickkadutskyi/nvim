
_G.Utils = require("kdtsk.utils")

-- Loads all the options
require("kdtsk.config.options")


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

    -- Setting it here delayed to avoid '"[No Name]" --No lines in buffer--' message
    vim.opt.cmdheight = 0
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
    performance = {
        -- Don't reset paths to let vim.pack.add work
        reset_packpath = false,
        rtp = {
            reset = false,
        },
    },
    -- profiling = {
    --     -- Enables extra stats on the debug tab related to the loader cache.
    --     -- Additionally gathers stats about all package.loaders
    --     loader = true,
    --     -- Track each new require in the Lazy profiling tab
    --     require = true,
    -- },
})

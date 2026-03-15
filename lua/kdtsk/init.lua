_G.Utils = require("kdtsk.utils")

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

-- Loads Settings modules via Lazy.nvim
require("lazy").setup({
    spec = {
        -- Configures all editor specific parts (completion, code style and quality, color scheme, etc.)
        { import = "kdtsk.settings.editor" },
        -- Everything related to version control systems (e.g. Git)
        { import = "kdtsk.settings.version_control" },
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

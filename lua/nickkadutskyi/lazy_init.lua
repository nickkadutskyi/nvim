-- Bootstrap lazy.nvim
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

-- Initializing lazy.nvim
require("lazy").setup({
    spec = {
        { import = "nickkadutskyi.appearance_behavior" },
        { import = "nickkadutskyi.editor" },
        { import = "nickkadutskyi.version_control" },
        { import = "nickkadutskyi.plugins" },
        { import = "nickkadutskyi.languages_frameworks" },
        { import = "nickkadutskyi.tools" },
    },
    change_detection = {
        enable = true,
        notify = false,
    },
    ui = {
        border = "rounded",
        title = { { " Plugin Manager ", "JBFloatBorder" } },
    },
    dev = {
        path = "~/Developer/PE/0027",
        patterns = { "nickkadutskyi" },
        fallback = true,
    },
})

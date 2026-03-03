local utils = require("ide.utils")

--- MODULE DEFINITION ----------------------------------------------------------

local M = {}
local I = {}

function M.setup()
end

-- If opened a dir then set it as the cwd and if opened a file then set the
-- file's parent dir as the cwd to narrow down the scope for fzf
-- Later ahmedkhalf/project.nvim will adjust cwd based on .git or LSP
local curr_path = vim.fn.resolve(vim.fn.expand("%"))
if vim.fn.isdirectory(vim.fn.expand("%")) == 1 then
    vim.api.nvim_set_current_dir(curr_path)
elseif vim.fn.filereadable(vim.fn.expand("%")) == 1 then
    vim.api.nvim_set_current_dir(vim.fn.fnamemodify(curr_path, ":p:h"))
end

--- Define custom autocmds
utils.autocmd.create("UIEnter", {
    once = true,
    callback = function()
        vim.api.nvim_exec_autocmds("User", { pattern = "IdeLater", modeline = false })
    end,
})

--- Handle settings
utils.autocmd.create("VimEnter", {
    once = true,
    callback = function()
        -- Set vim.g.settings and call SettingsLoaded autocmd in .nvim.lua
        -- to have project specific settings otherwise it's set to defaults
        if vim.g.settings == nil then
            vim.g.settings = {}
        end
        vim.api.nvim_command("doautocmd User SettingsLoaded")
    end,
})

--- Configure loader for local development versions of plugins.
require("ide.dev").setup()

return M

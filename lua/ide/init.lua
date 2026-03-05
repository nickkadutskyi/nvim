local utils = require("ide.utils")

--- MODULE DEFINITION ----------------------------------------------------------

local M = {}
local I = {}

---@param opts settings.Opts
function M.setup(opts)
    -- If opened a dir then set it as the cwd and if opened a file then set the
    -- file's parent dir as the cwd to narrow down the scope for fzf
    -- Later ahmedkhalf/project.nvim will adjust cwd based on .git or LSP
    local curr_path = vim.fn.resolve(vim.fn.expand("%"))
    if vim.fn.isdirectory(vim.fn.expand("%")) == 1 then
        vim.api.nvim_set_current_dir(curr_path)
    elseif vim.fn.filereadable(vim.fn.expand("%")) == 1 then
        vim.api.nvim_set_current_dir(vim.fn.fnamemodify(curr_path, ":p:h"))
    end

    if vim.fn.has("nvim-0.12.0") ~= 1 then
        return vim.notify("ide requires Neovim >= 0.12.0", vim.log.levels.ERROR, { title = "ide" })
    end
    if not (pcall(require, "ffi") and jit and jit.version) then
        return vim.notify("ide requires Neovim built with LuaJIT", vim.log.levels.ERROR, { title = "ide" })
    end

    utils.autocmd.create("IdeDone", {
        once = true,
        callback = function()
            if vim.v.vim_did_enter == 1 then
                utils.run.later(function()
                    vim.api.nvim_exec_autocmds("User", { pattern = "IdeLater", modeline = false })
                end)
            else
                utils.autocmd.create("UIEnter", {
                    once = true,
                    callback = function()
                        utils.run.later(function()
                            vim.api.nvim_exec_autocmds("User", { pattern = "IdeLater", modeline = false })
                        end)
                    end,
                })
            end
        end,
    })

    require("settings").setup(opts)

    vim.api.nvim_exec_autocmds("User", { pattern = "IdeDone", modeline = false })
end

--- Define custom autocmds

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

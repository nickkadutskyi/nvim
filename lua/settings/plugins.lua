local utils = require("ide.utils")
local g = utils.prepend_fn("https://github.com/")

--- MODULE DEFINITION ----------------------------------------------------------

---@class settings.Plugins
local M = {}
local I = {}

---@type vim.pack.Spec[]
M.plugins = {
    -- Pinned it on 6/24/25 due to bad update in next commit
    { src = g("rcarriga/nvim-notify"), version = "ab98fecfe" },
}
---@type table<string, {spec: vim.pack.Spec, path: string}>
M.loaded = {}

--- INTERNAL FUNCTIONS ---------------------------------------------------------

---@type vim.pack.OnLoad
function I.on_load(plugin_data)
    local spec = plugin_data.spec

    if spec.data and spec.data.enabled == false then
        return
    end

    vim.cmd.packadd(spec.name)
    M.loaded[spec.name] = plugin_data
end

function I.create_autocmds()
    local group = vim.api.nvim_create_augroup("settings.plugins", {})

    -- TODO: implement this autocmd
    -- vim.api.nvim_create_autocmd("PackChangedPre", {
    --     group = group,
    --     ---@param e settings.PackEvent
    --     callback = function(e) end,
    --     desc = "Placeholder for pre-change events, currently unused",
    -- })

    vim.api.nvim_create_autocmd("PackChanged", {
        group = group,
        ---@param e settings.PackEvent
        callback = function(e)
            -- Run build function if plugin is being installed or updated and has a build function
            if
                e.active
                and (e.kind == "install" or e.kind == "update")
                and e.spec.data
                and type(e.spec.data.build) == "function"
            then
                e.spec.data.build(e)
            end
        end,
        desc = "Handles post-install/update events for plugins, running build functions if defined",
    })
end

--- MODULE INITIALIZATION ---------------------------------------------------------

I.create_autocmds()
-- Load plugins
vim.pack.add(M.plugins, { load = I.on_load, confirm = true })

return M

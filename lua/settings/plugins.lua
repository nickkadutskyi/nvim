local utils = require("ide.utils")
local g = utils.prepend_gh

---@type ide.Plugins
local M = {
    loaded = {},
}

---@type vim.pack.Spec[]
local plugins = {
    -- Pinned it on 6/24/25 due to bad update in next commit
    { src = g("rcarriga/nvim-notify"), version = "ab98fecfe" },
}

---@type vim.pack.OnLoad
local on_load = function(plugin_data)
    local spec = plugin_data.spec

    if spec.data and spec.data.enabled == false then
        return
    end

    vim.cmd.packadd(spec.name)
    M.loaded[spec.name] = plugin_data
end

vim.api.nvim_create_autocmd("PackChangedPre", {
    ---@param e settings.PackEvent
    callback = function(e) end,
})

vim.api.nvim_create_autocmd("PackChanged", {
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
})

-- Load plugins
vim.pack.add(plugins, { load = on_load, confirm = true })

return M

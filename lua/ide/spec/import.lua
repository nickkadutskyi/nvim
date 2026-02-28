--- MODULE DEFINITION ----------------------------------------------------------
local M = {}
local I = {}

---Require all .lua files under a module directory, alphabetically.
---Equivalent to lazy.nvim's { import = "modname" }.
---@param modname string dotted module path, e.g. "settings.behavior"
function M.import(modname)
    -- Convert module name to filesystem path
    local relpath = modname:gsub("%.", "/")

    -- Try directory first, then fall back to a single .lua file
    local root
    for _, p in ipairs(vim.api.nvim_get_runtime_file("lua/" .. relpath, false)) do
        root = p
        break
    end

    if not root then
        -- Single-file module: just require it directly
        local found = vim.api.nvim_get_runtime_file("lua/" .. relpath .. ".lua", false)
        if found[1] then
            I.requiremod(modname)
            return
        end
        vim.notify("ide.spec.import: not found for '" .. modname .. "'", vim.log.levels.WARN)
        return
    end

    local mods = {}
    local handle = vim.uv.fs_scandir(root)
    while handle do
        local name, t = vim.uv.fs_scandir_next(handle)
        if not name then
            break
        end
        if name == "init.lua" then
            table.insert(mods, { modname = modname, path = root .. "/" .. name })
        elseif (t == "file" or t == "link") and name:sub(-4) == ".lua" then
            table.insert(mods, { modname = modname .. "." .. name:sub(1, -5), path = root .. "/" .. name })
        elseif t == "directory" and vim.uv.fs_stat(root .. "/" .. name .. "/init.lua") then
            table.insert(mods, { modname = modname .. "." .. name, path = root .. "/" .. name .. "/init.lua" })
        end
    end

    table.sort(mods, function(a, b)
        return a.modname < b.modname
    end)

    for _, mod in ipairs(mods) do
        I.requiremod(mod.modname)
    end
end

--- INTERNAL FUNCTIONS ---------------------------------------------------------

---@param modname string resolved module path
function I.requiremod(modname)
    local ok, err = pcall(require, modname)
    if not ok then
        vim.notify("ide.spec.import: failed to load '" .. modname .. "': " .. tostring(err), vim.log.levels.ERROR)
    end
end

return M

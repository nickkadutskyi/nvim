local utils = require("ide.utils")

--- MODULE DEFINITION ----------------------------------------------------------
---@class ide.Utils.Tool
local M = {}
local I = {}

---@param test ide.ToolTest
function M.is_enabled(test)
    if test[3] == true then
        return true
    elseif test[3] == false then
        return false
    end

    local patterns = test[1]
    if patterns and #patterns > 0 and utils.fs.file_exists(patterns, "any") then
        return true
    end

    local fn = test[2]
    if fn and type(fn) == "function" then
        local res = fn()
        return type(res) == "boolean" and res or false
    end

    return false
end

---@param tools_by_ft table<string,table<ide.Tool>>
function M.resolve_by_ft(tools_by_ft)
    local resolved = {}
    for ft, tools in pairs(tools_by_ft) do
        resolved[ft] = vim.iter(tools)
            :filter(function(tool)
                return M.is_enabled({ tool[2], tool[3], tool[4] })
            end)
            :fold({}, function(acc, v)
                local only_opts = v[1]:sub(1, 1) == "_"
                return utils.table.merge_lists_dicts(acc, v[5] or {}, only_opts and {} or { v[1] })
            end)
    end
    return resolved
end

return M

--- MODULE DEFINITION ----------------------------------------------------------
---@class ide.Utils.Table
local M = {}
local I = {}

--- Adds or removes items from a list based on add and remove lists.
---@param list table The original list to modify
---@param add? table Items to add to the list
---@param remove? table Items to remove from the list
function M.list_add_rem(list, add, remove)
    local set = {}
    for _, item in ipairs(list) do
        set[item] = true
    end
    for _, item in ipairs(add or {}) do
        set[item] = true
    end
    for _, item in ipairs(remove or {}) do
        set[item] = nil
    end

    local result = {}
    for item, _ in pairs(set) do
        table.insert(result, item)
    end
    return result
end

function M.merge_lists_dicts(...)
    local tables = { ... }
    local out = vim.deepcopy(tables[1])

    for i = 2, #tables do
        local t = tables[i]

        -- merge the list part on this level
        vim.list_extend(out, t)

        for k, v in pairs(t) do
            if type(k) ~= "number" then
                out[k] = v
            end
        end
    end

    return out
end

return M

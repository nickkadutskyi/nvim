--- MODULE DEFINITION ----------------------------------------------------------

---@class ide.Utils.Str
local M = {}
local I = {}

---@param prefix string prefix to prepend
function M.prepend_fn(prefix)
    ---@param str string string to prepend prefix to
    return function(str)
        return "" .. prefix .. str
    end
end

return M

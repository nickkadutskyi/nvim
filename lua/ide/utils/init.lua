---@class ide.Utils
---@field run ide.Utils.Run
local M = {}

setmetatable(M, {
    __index = function(_, key)
        local module = require("ide.utils." .. key)
        rawset(M, key, module)
        return module
    end,
})

---@param prefix string prefix to prepend
function M.prepend_fn(prefix)
    ---@param str string string to prepend prefix to
    return function(str)
        return "" .. prefix .. str
    end
end

return M

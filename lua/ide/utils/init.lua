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

---Prepends github url to a repo string
---@param repo string in the format "owner/repo"
function M.prepend_gh(repo)
    return "https://github.com/" .. repo
end

return M

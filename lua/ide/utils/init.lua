---@class ide.Utils
---@field run ide.Utils.Run
---@field autocmd ide.Utils.Autocmd
---@field str ide.Utils.Str
---@field treesitter ide.Utils.Plugins.Treesitter
local M = {}

setmetatable(M, {
    __index = function(_, key)
        local module = require("ide.utils." .. key)
        rawset(M, key, module)
        return module
    end,
})

return M

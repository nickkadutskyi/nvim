---@class ide.Utils
---@field run ide.Utils.Run
---@field autocmd ide.Utils.Autocmd
---@field str ide.Utils.Str
---@field treesitter ide.Utils.Plugins.Treesitter
---@field tabline ide.Utils.Tabline
local M = {}

setmetatable(M, {
    __index = function(_, key)
        local module = require("ide.utils." .. key)
        rawset(M, key, module)
        return module
    end,
})

---@enum ide.Purpose
M.purpose = {
    LSP = 1,
    INSPECT = 2,
    STYLE = 3,
    [1] = "LSP",
    [2] = "INSPECT",
    [3] = "STYLE",
}

return M

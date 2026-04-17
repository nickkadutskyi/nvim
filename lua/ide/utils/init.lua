---@class ide.Utils
---@field run ide.Utils.Run
---@field autocmd ide.Utils.Autocmd
---@field str ide.Utils.Str
---@field treesitter ide.Utils.Plugins.Treesitter
---@field tabline ide.Utils.Tabline
---@field tool ide.Utils.Tool
---@field fs ide.Utils.Fs
---@field table ide.Utils.Table
local M = {}

setmetatable(M, {
    __index = function(_, key)
        local module = require("ide.utils." .. key)
        rawset(M, key, module)
        return module
    end,
})

---Determines if the current environment is a Nix shell.
---@return nil|"pure"|"impure"|"unknown"
function M.nix_shell_type()
    local nix_shell = os.getenv("IN_NIX_SHELL")
    if nix_shell ~= nil then
        return nix_shell
    else
        local path = os.getenv("PATH") or ""
        if path:find("/nix/store", 1, true) then
            return "unknown"
        end
    end
    return nil
end

return M

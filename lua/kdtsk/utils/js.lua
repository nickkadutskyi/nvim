---@class kdtsk.utils.js
local M = {}

---Find the PHP executable in the current working directory in PHP specific
---locations or globally with cache support to avoid repeated lookups.
---@param executable string The name of the PHP executable to find (e.g., "phpcs", "phpstan")
---@param cwd? string Optional current working directory to search in (defaults to vim.fn.getcwd())
---@return string|nil
function M.find_executable(executable, cwd)
    local bin, found = Utils.tools.find_executable({
        "./node_modules/.bin/" .. executable,
        ".devenv/profile/bin/" .. executable,
    }, executable, cwd)
    return found and bin or nil
end

return M

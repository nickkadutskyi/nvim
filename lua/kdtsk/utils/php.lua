---@class kdtsk.utils.php
local M = {}

---@return string|nil
function M.find_executable(executable, cwd)
    local bin, found = Utils.tools.find_executable({
        "./" .. executable .. ".phar",
        "vendor/bin/" .. executable,
        "vendor/bin/" .. executable .. ".phar",
        ".devenv/profile/bin/" .. executable,
    }, executable, cwd)
    return found and bin or nil
end

return M

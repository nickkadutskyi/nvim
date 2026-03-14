local utils = require("ide.utils")

--- MODULE DEFINITION ----------------------------------------------------------
---@class ide.Utils.Tool
local M = {}
local I = {}

I.cache = {
    -- Cache for memoizing find_executable results
    ---@type table<string, {result: string, found: boolean}>
    executables = {},
}

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

--- Find an executable in the given paths, checking both absolute and relative paths.
--- If found cache the result to avoid repeated lookups.
---@param paths string[]
---@param default string
---@param cwd? string
---@return boolean found Whether the executable was found
---@return string result The path to the executable if found, otherwise the default value
function M.find_executable(paths, default, cwd)
    -- Create a cache key based on the inputs
    cwd = cwd or vim.fn.getcwd()
    local cache_key = table.concat(paths, "|") .. ":" .. default .. ":" .. cwd
    if I.cache.executables[cache_key] then
        return I.cache.executables[cache_key].found, I.cache.executables[cache_key].result
    end

    for _, path in ipairs(paths) do
        local normpath = vim.fs.normalize(path)
        local is_absolute = vim.startswith(normpath, "/")
        if is_absolute and vim.fn.executable(normpath) then
            I.cache.executables[cache_key] = { result = normpath, found = true }
            return true, normpath
        end

        local idx = normpath:find("/", 1, true)
        local dir, subpath
        if idx then
            dir = normpath:sub(1, idx - 1)
            subpath = normpath:sub(idx)
        else
            -- This is a bare relative-path executable
            dir = normpath
            subpath = ""
        end
        local results = vim.fs.find(dir, { upward = true, path = cwd, limit = math.huge })
        for _, result in ipairs(results) do
            local fullpath = result .. subpath
            if vim.fn.executable(fullpath) == 1 then
                I.cache.executables[cache_key] = { result = fullpath, found = true }
                return true, fullpath
            end
        end

        -- If no subpath (bare executable name), also check in PATH
        if subpath == "" and vim.fn.executable(normpath) == 1 then
            -- Use vim.fn.exepath to get the full path from PATH
            local path_result = vim.fn.exepath(normpath)
            if path_result ~= "" then
                I.cache.executables[cache_key] = { result = path_result, found = true }
                return true, path_result
            end
        end
    end

    -- Before falling back to default, check if default is available in PATH
    if vim.fn.executable(default) == 1 then
        local path_result = vim.fn.exepath(default)
        if path_result ~= "" then
            I.cache.executables[cache_key] = { result = path_result, found = true }
            return true, path_result
        end
    end

    I.cache.executables[cache_key] = { result = default, found = false }
    return false, default
end

---Find the PHP executable in the current working directory in PHP specific
---locations or globally with cache support to avoid repeated lookups.
---@param executable string The name of the PHP executable to find (e.g., "phpcs", "phpstan")
---@param cwd? string Optional current working directory to search in (defaults to vim.fn.getcwd())
---@return string|nil bin_path The path to the PHP executable if found, otherwise nil
function M.find_php_executable(executable, cwd)
    local found, bin = M.find_executable({
        "./" .. executable,
        "./" .. executable .. ".phar",
        "vendor/bin/" .. executable,
        "vendor/bin/" .. executable .. ".phar",
        ".devenv/profile/bin/" .. executable,
    }, executable, cwd)
    return found and bin or nil
end

return M

---@class kdtsk.utils.tools
local M = {}

-- Cache for memoizing find_executable results
local cache = {}

---@param paths string[]
---@param default string
---@param cwd? string
---@return string, boolean
function M.find_executable(paths, default, cwd)
    -- Create a cache key based on the inputs
    cwd = cwd or vim.fn.getcwd()
    local cache_key = table.concat(paths, "|") .. ":" .. default .. ":" .. cwd
    if cache[cache_key] then
        return cache[cache_key].result, cache[cache_key].found
    end

    for _, path in ipairs(paths) do
        local normpath = vim.fs.normalize(path)
        local is_absolute = vim.startswith(normpath, "/")
        if is_absolute and vim.fn.executable(normpath) then
            cache[cache_key] = { result = normpath, found = true }
            return normpath, true
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
                cache[cache_key] = { result = fullpath, found = true }
                return fullpath, true
            end
        end

        -- If no subpath (bare executable name), also check in PATH
        if subpath == "" and vim.fn.executable(normpath) == 1 then
            -- Use vim.fn.exepath to get the full path from PATH
            local path_result = vim.fn.exepath(normpath)
            if path_result ~= "" then
                cache[cache_key] = { result = path_result, found = true }
                return path_result, true
            end
        end
    end

    -- Before falling back to default, check if default is available in PATH
    if vim.fn.executable(default) == 1 then
        local path_result = vim.fn.exepath(default)
        if path_result ~= "" then
            cache[cache_key] = { result = path_result, found = true }
            return path_result, true
        end
    end

    cache[cache_key] = { result = default, found = false }
    return default, false
end

---Clear the find_executable cache
---@return nil
function M.clear_executable_cache()
    cache = {}
end

---Check if a file or path exists in the current working directory
---@param paths string|string[] The file or directory path(s) to check
---@param cwd? string Optional current working directory (defaults to vim.fn.getcwd())
---@return boolean, string|nil - True if any of the file/path exists, false otherwise
function M.file_exists(paths, cwd)
    cwd = cwd or vim.fn.getcwd()

    -- Handle single path string
    if type(paths) == "string" then
        paths = { paths }
    end

    -- Check each path
    for _, path in ipairs(paths) do
        local full_path = vim.fs.normalize(vim.fs.joinpath(cwd, path))

        -- Check if it's a file or directory
        local stat = vim.loop.fs_stat(full_path)
        if stat ~= nil then
            return true, full_path
        end
    end

    return false, nil
end


return M

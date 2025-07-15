---@class kdtsk.utils.tools
local M = {}

-- Cache for memoizing find_executable results
local cache = {}

---Find an executable in the given paths, checking both absolute and relative paths.
---If found cache the result to avoid repeated lookups.
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

---@enum kdtsk.tools.Purpose
M.purpose = {
    LSP = 1,
    INSPECTION = 2,
    STYLE = 3,
    [1] = "LSP",
    [2] = "INSPECTION",
    [3] = "STYLE",
}

---@param purpose string|kdtsk.tools.Purpose
---@return kdtsk.tools.Purpose?
local function to_purpose(purpose)
    if type(purpose) == "string" then
        assert(M.purpose[string.upper(purpose)], string.format("Invalid purpose: %s", purpose))
        return M.purpose[string.upper(purpose)]
    end
    return purpose
end

---@alias kdtsk.tools.Scope
---| '"php"'
---| '"lua"'
---| '"typescript"'
---| '"javascript"'
---| '"python"'
---| '"go"'

---@param scope kdtsk.tools.Scope Scope to use the tool within (e.g. php)
---@param component string Name of the tool, language server, plugin, etc.
---@param purpose kdtsk.tools.Purpose Purpose for which the tool is enabled
---@param patterns ?string[] Patterns to match the tool's config file
function M.is_component_enabled(scope, component, purpose, patterns)
    local purposeStr = type(purpose) == "number" and M.purpose[purpose] or purpose
    -- Check if the tool is enabled via .nvim.lua settings
    local ok, enabled = Utils.run_when_settings_loaded(function(settings)
        local tool = settings[scope] and settings[scope][component]
        if type(tool) == "table" then
            local use_for = type(tool.use_for) == "table" and tool.use_for or {}
            return use_for[purposeStr]
        end
    end)
    if ok and enabled ~= nil then
        return enabled
    end
    return patterns and Utils.tools.file_exists(patterns) or false
end

local function deep_merge_lists(...)
    local tables = { ... }
    local out = vim.deepcopy(tables[1])

    for i = 2, #tables do
        local t = tables[i]

        -- merge the dict part
        out = vim.tbl_deep_extend("keep", out, t)

        -- merge the list part on this level
        vim.list_extend(out, t)

        -- if both sides have a key that is itself a table we have to
        -- merge their list parts as well
        for k, v in pairs(t) do
            if type(v) == "table" and type(out[k]) == "table" then
                vim.list_extend(out[k], v)
            end
        end
    end

    return out
end

---@param tbl1 table First table to extend
---@param tbl2 table Second table to extend
---@param comp {
---  [1]: kdtsk.tools.Scope, # Scope of the component (e.g. "php")
---  [2]: string, # Name of the component (e.g. "phpactor")
---  [3]: kdtsk.tools.Purpose, # Purpose of the component (e.g. "LSP")
---  [4]: string[], # Patterns to match the tool's config file
--- } Component to check if enabled
function M.extended_if_enabled(tbl1, tbl2, comp)
    if M.is_component_enabled(unpack(comp)) then
        return deep_merge_lists(tbl1, tbl2)
    else
        return tbl1
    end
end

---Determines if a command can be run directly or needs to be run via Nix.
---Uses Nix to run the command only if outside of a Nix shell because
---Nix shells have to provide the environment for the command to run.
---@param command string|function|table Command to run
---@return boolean, boolean, string (directly, via_nix, command)
function M.run_command_via(command)
    command = type(command) == "function" and command() or command
    command = type(command) == "table" and command[1] or command
    assert(
        type(command) == "string" and command ~= "",
        "Command must be a non-empty string, but got: " .. vim.inspect(command)
    )
    if vim.fn.executable(command) == 1 then
        return true, false, command
    elseif vim.fn.executable("nix") == 1 and Utils.nix.nix_shell_type() == nil then
        return false, true, command
    else
        return false, false, command
    end
end

return M

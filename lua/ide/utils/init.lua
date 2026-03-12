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

---Check if a file or path exists in the current working directory
---@param paths string|string[] The file or directory path(s) to check
---@param logic? "any"|"all" "any" (default) to check if any path exists, "all" to check if all paths exist
---@param cwd? string Optional current working directory (defaults to vim.fn.getcwd())
---@return boolean, string|nil - True if any of the file/path exists, false otherwise
function M.file_exists(paths, logic, cwd)
    vim.validate("paths", paths, { "string", "table" }, "path or list of paths")
    vim.validate("logic", logic, function(v)
        return v == nil or v == "any" or v == "all"
    end, true, '"any" or "all"')
    vim.validate("cwd", cwd, { "string" }, true, "current working directory string")

    cwd = cwd or vim.fn.getcwd()
    logic = logic or "any"
    if type(paths) == "string" then
        paths = { paths }
    end

    for _, path in ipairs(paths) do
        local full_path = vim.fs.normalize(vim.fs.joinpath(cwd, path))
        local stat = vim.loop.fs_stat(full_path)
        if stat ~= nil then
            if logic == "any" then
                return true, full_path
            end
        else
            if logic == "all" then
                return false, nil
            end
        end
    end

    return logic == "all", nil
end

---@param tools_by_ft table<string,table<ide.Tool>>
function M.resolve_tools_by_ft(tools_by_ft)
    local resolved = {}
    for ft, tools in pairs(tools_by_ft) do
        resolved[ft] = vim.iter(tools)
            :filter(function(tool)
                if tool[4] == true then
                    return true
                elseif tool[4] == false then
                    return false
                end

                local patterns = tool[2]
                if patterns and #patterns > 0 and M.file_exists(patterns, "any") then
                    return true
                end

                local fn = tool[3]
                if fn and type(fn) == "function" then
                    local res = fn()
                    return type(res) == "boolean" and res or false
                end

                return false
            end)
            :fold({}, function(acc, v)
                -- merging with options
                local res = vim.deepcopy(v[5] or {})
                vim.list_extend(res, acc)
                table.insert(res, v[1])

                return res
            end)
    end
    return resolved
end

--- Adds or removes items from a list based on add and remove lists.
---@param list table The original list to modify
---@param add? table Items to add to the list
---@param remove? table Items to remove from the list
function M.list_add_rem(list, add, remove)
    local set = {}
    for _, item in ipairs(list) do
        set[item] = true
    end
    for _, item in ipairs(add or {}) do
        set[item] = true
    end
    for _, item in ipairs(remove or {}) do
        set[item] = nil
    end

    local result = {}
    for item, _ in pairs(set) do
        table.insert(result, item)
    end
    return result
end

return M

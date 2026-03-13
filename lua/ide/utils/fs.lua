--- MODULE DEFINITION ----------------------------------------------------------
---@class ide.Utils.Fs
local M = {}
local I = {}

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

return M

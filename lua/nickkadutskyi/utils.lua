local defaults = require("nickkadutskyi.config").default

local M = {}

---Search parent directories for a relative path to a command
---@param paths string[]
---@param default string
---@param cwd? string
---@return string
---@example
--- local cmd = require("nickkadutskyi.util").find_executable({ "node_modules/.bin/prettier" }, "prettier")
function M.find_executable(paths, default, cwd)
    cwd = cwd or vim.fn.getcwd()
    for _, path in ipairs(paths) do
        local normpath = vim.fs.normalize(path)
        local is_absolute = vim.startswith(normpath, "/")
        if is_absolute and vim.fn.executable(normpath) then
            return normpath
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
                return fullpath
            end
        end
    end

    return default
end

function M.git_status(path, callback)
    -- Create a temporary buffer for job output
    local output = ""

    -- Build the git command to check file status
    local cmd = { "git", "status", "--porcelain", "--ignored", path }

    -- Create the job
    local job_id = vim.fn.jobstart(cmd, {
        stdout_buffered = true,
        on_stdout = function(_, data)
            if data then
                output = table.concat(data, "\n")
            end
        end,
        on_exit = function(_, exit_code)
            -- Parse the git status output
            local status_code = ""
            if exit_code == 0 and output ~= "" then
                -- Get the first two characters which represent the status code
                status_code = output:sub(1, 2)
            end

            -- Call the callback with the result
            if callback then
                callback(status_code, exit_code)
            end
        end,
    })

    -- Check if job creation was successful
    if job_id <= 0 then
        vim.notify("Failed to start git status check", vim.log.levels.ERROR)
        if callback then
            callback("", -1)
        end
    end
end

function M.set_git_status_hl(bufnr)
    local bufnr_valid = vim.api.nvim_buf_is_valid(bufnr)
    local file = bufnr_valid and vim.fn.fnamemodify(vim.fn.bufname(bufnr), ":p") or nil
    if file then
        local cwd = vim.fn.getcwd()
        local is_in_cwd = file:find(cwd, 1, true) == 1
        if is_in_cwd then
            local path_stat = vim.loop.fs_stat(file)
            if path_stat and path_stat.type == "file" then
                M.git_status(file, function(status_code)
                    local still_bufnr_valid = vim.api.nvim_buf_is_valid(bufnr)
                    if not still_bufnr_valid then
                        return
                    end
                    if status_code == "??" then
                        vim.b[bufnr].custom_git_status_hl = "VCS_Unknown_StatusLine"
                    elseif status_code == "!!" then
                        vim.b[bufnr].custom_git_status_hl = "VCS_Ignored_StatusLine"
                    elseif status_code:match("^A[^A]") then
                        vim.b[bufnr].custom_git_status_hl = "VCS_Added_StatusLine"
                    elseif status_code:match("^D ") then
                        vim.b[bufnr].custom_git_status_hl = "VCS_Deleted_StatusLine"
                    elseif status_code:match("^[^D]D]") then
                        vim.b[bufnr].custom_git_status_hl = "VCS_DeletedFromFileSystem_StatusLine"
                    elseif status_code:match("[MT]") then
                        vim.b[bufnr].custom_git_status_hl = "VCS_Modified_StatusLine"
                    elseif status_code:match("[R]") then
                        vim.b[bufnr].custom_git_status_hl = "VCS_Renamed_StatusLine"
                    elseif status_code:match("[UDA]") then
                        vim.b[bufnr].custom_git_status_hl = "VCS_MergedWithConflicts_StatusLine"
                    else
                        vim.b[bufnr].custom_git_status_hl = "Custom_TabSel"
                    end
                end)
            end
        else -- Not in the current project
            vim.b[bufnr].custom_git_status_hl = "Appearance_FileColors_NonProjectFile"
        end
        local ok, lualine = pcall(require, "lualine")
        if ok then
            lualine.refresh()
        end
    end
end

---@param path string
---@param paths string[]|string
function M.is_path_in_paths(path, paths)
    path = vim.fn.fnamemodify(path, ":p")
    if type(paths) == "string" then
        paths = { paths }
    end
    for _, p in ipairs(paths) do
        if path:find(vim.fn.fnamemodify(p, ":p"), 1, true) == 1 then
            return true
        end
    end
end

---@param item any
---@param table_name string
---@return any[] -- Copy of the global table
function M.add_to_global_list(item, table_name)
    if type(vim.g[table_name]) == "table" then
        local l_table = vim.g[table_name]
        table.insert(l_table, item)
        vim.g[table_name] = l_table
    elseif vim.g[table_name] == nil then
        vim.g[table_name] = { item }
    else
        error("Variable is not a table. " .. table_name .. " is a " .. type(vim.g[table_name]))
    end
    return vim.g[table_name]
end

---Copilot (github/copilot.vim) configuration
function M.add_cwd_to_copilot_workspace_folders()
    local cwd = vim.fn.getcwd()
    if M.is_path_in_paths(cwd, defaults.copilot_allowed_paths) then
        M.add_to_global_list(cwd, "copilot_workspace_folders")
    else
        vim.notify(
            "Current directory (" .. cwd .. ") is not in the allowed paths for Copilot",
            vim.log.levels.WARN,
            { title = "Utils.Copilot" }
        )
    end
end

return M

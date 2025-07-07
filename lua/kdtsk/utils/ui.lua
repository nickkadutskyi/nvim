---@class kdtsk.utils.ui
local M = {}

-- Ensures relative file path if there are multiple files with same name in project
function M.titlestring()
    local devpath = vim.fn.fnamemodify("~/Documents", ":p")
    local cwd = vim.fn.getcwd()
    local projectName = vim.fn.fnamemodify(cwd, ":t")
    local project = projectName
    if cwd:find(devpath, 1, true) == 1 then
        local code = vim.fs.basename(vim.fs.dirname(cwd))
        code = tonumber(code) or code
        local account = vim.fs.basename(vim.fs.dirname(vim.fn.fnamemodify(cwd, ":h")))
        project = account .. "" .. code .. " " .. projectName
    end
    local rootPath = vim.fn.resolve(vim.fn.getcwd())
    local relativeFilePath = vim.fn.expand("%")
    local filePath = vim.fn.expand("%:p")
    local fileName = vim.fn.expand("%:t")
    local home = vim.env.HOME .. "/"
    local all_files_str = vim.g.all_files_str or ""
    local delim = fileName ~= "" and " – " or ""

    local title_filename
    -- If Neovim didn't define all_files_str variable
    if string.match(relativeFilePath, "^term://") then
        local path_parts = vim.fn.split(relativeFilePath, ":")
        title_filename = "term " .. path_parts[#path_parts]
    elseif string.match(relativeFilePath, "^.*://") then
        title_filename = relativeFilePath
    elseif all_files_str == "" then
        if string.match(filePath, "^" .. home) and vim.fn.resolve(filePath) ~= filePath then
            -- if file is in home directory and symlink
            title_filename = "./" .. vim.fn.fnamemodify(filePath, ":t")
        else
            title_filename = vim.fn.fnamemodify(vim.fn.resolve(filePath), ":~:.:h") .. "/" .. vim.fn.expand("%:t")
        end
    else
        -- Count occurrences of fileName in all_files_str
        local count = select(2, string.gsub(all_files_str, fileName, ""))

        if count > 1 then -- if other files with same name exist in project
            title_filename = vim.fn.fnamemodify(vim.fn.resolve(filePath), ":~:.:h") .. "/" .. vim.fn.expand("%:t")
        elseif count == 0 then -- if not in project
            if string.match(relativeFilePath, "^term://") then
                local path_parts = vim.fn.split(relativeFilePath, ":")
                title_filename = "term " .. path_parts[#path_parts]
            else
                title_filename = relativeFilePath
            end
        elseif string.sub(filePath, 1, #rootPath) == rootPath then -- if file is in root directory
            title_filename = fileName
        else
            title_filename = vim.fn.fnamemodify(vim.fn.resolve(filePath), ":~:.:h") .. "/" .. vim.fn.expand("%:t")
        end
    end

    -- Get SSH connection info if available
    local ssh_connection = os.getenv("SSH_CONNECTION")
    local host_prefix = ""

    if ssh_connection then
        local user = vim.fn.expand("$USER")
        local hostname = vim.fn.hostname()
        host_prefix = string.format("[%s@%s] ", user, hostname)
    end

    -- return project .. (delim ~= "" and delim .. title_filename or "")
    return host_prefix .. project .. " - " .. title_filename .. " (nvim)"
end

return M

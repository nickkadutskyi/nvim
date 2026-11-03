---@class kdtsk.utils.ui
local M = {}

-- Uses the shortest unique path suffix for files in the current project.
function M.titlestring()
    local devpath = vim.fn.fnamemodify("~/Documents", ":p")
    local cwd = vim.fn.getcwd()
    local projectName = vim.fn.fnamemodify(cwd, ":t")
    local project = projectName
    local relativeFilePath = vim.fn.expand("%")
    local filePath = vim.fn.expand("%:p")
    local fileName = vim.fn.expand("%:t")
    local home = vim.env.HOME .. "/"
    local project_files = vim.g.project_files
    local delim = fileName ~= "" and " – " or ""

    local title_filename
    if string.match(relativeFilePath, "^term://") then
        local path_parts = vim.fn.split(relativeFilePath, ":")
        title_filename = "term " .. path_parts[#path_parts]
    elseif string.match(relativeFilePath, "^.*://") then
        title_filename = relativeFilePath
    elseif not project_files or project_files.root ~= cwd or not vim.fs.relpath(cwd, filePath) then
        if string.match(filePath, "^" .. home) and vim.fn.resolve(filePath) ~= filePath then
            -- if file is in home directory and symlink
            title_filename = "./" .. vim.fn.fnamemodify(filePath, ":t")
        else
            title_filename = vim.fn.fnamemodify(vim.fn.resolve(filePath), ":~:.:h") .. "/" .. vim.fn.expand("%:t")
        end
    else
        title_filename = fileName
        local parent = vim.fs.dirname(filePath)
        while title_filename ~= "" do
            local duplicate = false
            for _, path in ipairs(project_files.paths) do
                local other = vim.fs.joinpath(cwd, path)
                if other ~= filePath and other:sub(-#title_filename - 1) == "/" .. title_filename then
                    duplicate = true
                    break
                end
            end
            if not duplicate then
                break
            end
            title_filename = vim.fs.basename(parent) .. "/" .. title_filename
            parent = vim.fs.dirname(parent)
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

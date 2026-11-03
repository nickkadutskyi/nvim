---@class kdtsk.utils.ui
local M = {}
local terminal_title = {}

-- Uses the shortest unique path suffix for files in the current project.
function M.titlestring()
    local devpath = vim.fn.fnamemodify("~/Documents", ":p")
    local cwd = vim.fn.getcwd()
    local projectName = vim.fn.fnamemodify(cwd, ":t")
    local project = projectName
    local relativeFilePath = vim.fn.expand("%")
    local filePath = vim.fn.expand("%:p")
    local fileName = vim.fn.expand("%:t")
    local project_files = vim.g.project_files
    local delim = fileName ~= "" and " – " or ""

    local title_filename
    if relativeFilePath == "" then
        title_filename = "[No Name]"
    elseif string.match(relativeFilePath, "^term://") then
        local command = relativeFilePath:match("//%d+:(.*)$") or vim.o.shell
        title_filename = "term " .. vim.fs.basename(command:match("^%S+") or command)
        local pid = vim.b.terminal_job_pid
        if pid then
            local now = vim.uv.hrtime() / 1e6
            -- Process queries can spawn ps; avoid doing that on every title redraw.
            if terminal_title.pid ~= pid or now - terminal_title.updated >= 1000 then
                local programs, seen = {}, {}
                local function collect_programs(process_pid)
                    local process = vim.api.nvim_get_proc(process_pid)
                    if not process then
                        return
                    end
                    local name = vim.fs.basename(process.name)
                    if not seen[name] then
                        seen[name] = true
                        programs[#programs + 1] = name
                    end
                    for _, child in ipairs(vim.api.nvim_get_proc_children(process_pid)) do
                        collect_programs(child)
                    end
                end
                collect_programs(pid)
                terminal_title = {
                    pid = pid,
                    updated = now,
                    title = #programs > 0 and "term " .. table.concat(programs, " → ") or title_filename,
                }
            end
            title_filename = terminal_title.title
        end
    elseif string.match(relativeFilePath, "^.*://") then
        title_filename = relativeFilePath
    elseif not project_files or project_files.root ~= cwd or not vim.fs.relpath(cwd, filePath) then
        title_filename = vim.fn.fnamemodify(filePath, ":~:.")
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
    return host_prefix .. project .. " - " .. title_filename
end

return M

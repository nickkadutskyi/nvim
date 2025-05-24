---@class kdtsk.utils.lsp
local M = {}

local config = {
    max_log_size = 10 * 1024 * 1024, -- 10 MB
    max_backup_files = 5,
}

function M.rotate_lsp_logs()
    local log_path = vim.fn.stdpath("state") .. "/lsp.log"
    if not vim.fn.filereadable(log_path) then
        log_path = vim.lsp.log.get_filename()
    end
    local backup_dir = vim.fn.stdpath("state") .. "/logs"
    vim.fn.mkdir(backup_dir, "p")

    if vim.fn.getfsize(log_path) > config.max_log_size then
        -- Rotate the log file
        local timestamp = os.date("%Y%m%d_%H%M%S")
        os.rename(log_path, backup_dir .. "/lsp_" .. timestamp .. ".log")
        vim.fn.writefile({}, log_path)

        -- Clean up old backups
        local backups = vim.fn.glob(backup_dir .. "/lsp_*.log", true, true)
        table.sort(backups, function(a, b)
            return vim.fn.getftime(a) > vim.fn.getftime(b)
        end)
        for i, file in ipairs(backups) do
            if i > config.max_backup_files then
                os.remove(file)
            end
        end
    end
end

return M

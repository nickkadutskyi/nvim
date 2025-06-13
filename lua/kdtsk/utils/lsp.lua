---@class kdtsk.utils.lsp
local M = {}

local config = {
    max_log_size = 1 * 1024 * 1024, -- 1 MB
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

---@class LspCommand: lsp.ExecuteCommandParams
---@field open? boolean
---@field handler? lsp.Handler

---@param opts LspCommand
function M.execute(opts)
    local params = {
        command = opts.command,
        arguments = opts.arguments,
    }
    if opts.open then
        require("trouble").open({
            mode = "lsp_command",
            params = params,
        })
    else
        return vim.lsp.buf_request(0, "workspace/executeCommand", params, opts.handler)
    end
end

--- Got it from core neovim
---@param bufnr integer
---@param conf vim.lsp.Config
function M.start_config(bufnr, conf)
    return vim.lsp.start(conf, {
        bufnr = bufnr,
        reuse_client = conf.reuse_client,
        _root_markers = conf.root_markers,
    })
end

---@param conf vim.lsp.Config
function M.create_clients_and_start_servers(conf)
    local buffers = vim.api.nvim_list_bufs()
    for _, buffer in ipairs(buffers) do
        if Utils.should_track_buffer(buffer, nil, Utils.array_to_list(conf.filetypes)) then
            -- Triggers FileType event but only in current buffer
            -- which runs `lsp_enable_callback` that runs `start_config`
            -- vim.cmd("edit")

            -- Do partially what core lsp_enable_callback does for each buffer
            if type(conf.root_dir) == "function" then
                ---@param root_dir string
                conf.root_dir(0, function(root_dir)
                    conf.root_dir = root_dir
                    vim.schedule(function()
                        M.start_config(0, conf)
                    end)
                end)
            else
                M.start_config(0, conf)
            end
        end
    end
end

--- Set up all language servers via this function
---@param name string
---@param cfg ?vim.lsp.ConfigLocal
function M.setup(name, cfg)
    cfg = cfg or {}

    -- Per language server config may turn off the server
    -- Use provided binary if not overwriting cmd
    if cfg.bin and not cfg.cmd then
        cfg.cmd = vim.lsp.config[name].cmd or {}
        cfg.cmd[1] = cfg.bin
    end

    -- Always configure but only enable if not disabled
    vim.lsp.config(name, cfg)
    if cfg.enabled ~= false then
        vim.lsp.enable(name)
    end
end

return M

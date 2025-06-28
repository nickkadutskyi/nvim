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

    if cfg.enabled ~= false then
        local project_cfg = (vim.g.settings or {})[name]
        if project_cfg then
            cfg.settings = vim.tbl_deep_extend("force", (cfg.settings or {}), (project_cfg.settings or {}))
        end
        vim.lsp.config(name, cfg)
        vim.lsp.enable(name)
    end
end

---@param default table Default configuration table
---@param relative_path string Path to the local configuration file
---@param name string Name of the configuration (for error messages)
function M.merge_with_local_config(default, relative_path, name)
    local has_local_config, config_path = Utils.tools.file_exists(relative_path)
    if has_local_config and config_path then
        local file = io.open(config_path, "r")
        if not file then
            error("Could not open config at " .. config_path)
        end
        local content = file:read("*a")
        file:close()
        local ok, local_config = pcall(vim.fn.json_decode, content)
        if ok and type(local_config) == "table" then
            return vim.tbl_deep_extend("force", default, local_config)
        else
            vim.notify("Invalid format in " .. config_path .. ", expected a JSON object", vim.log.levels.ERROR)
            return default
        end
    end

    return default
end

---@param name string Name of the tool or language server
---@param patterns ?string[] Patterns to match the tool's config file
function M.is_enabled(name, patterns)
    return Utils.tools.is_tool_enabled(name, "lsp", patterns)
end

return M

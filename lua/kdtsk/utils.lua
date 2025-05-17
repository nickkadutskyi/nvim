local defaults = require("kdtsk.config").default

local M = {}

---Search parent directories for a relative path to a command
---@param paths string[]
---@param default string
---@param cwd? string
---@return string
---@example
--- local cmd = require("kdtsk.util").find_executable({ "node_modules/.bin/prettier" }, "prettier")
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
    if file and vim.fn.filereadable(file) == 1 then
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
                    local ok, lualine = pcall(require, "lualine")
                    if ok and bufnr == vim.fn.bufnr() then
                        lualine.refresh()
                    end
                end)
            end
        else -- Not in the current project
            vim.b[bufnr].custom_git_status_hl = "Appearance_FileColors_NonProjectFile"
            local ok, lualine = pcall(require, "lualine")
            if ok and bufnr == vim.fn.bufnr() then
                lualine.refresh()
            end
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
    elseif not M.is_path_in_paths(cwd, defaults.copilot_not_allowed_paths) then
        vim.notify(
            "Current directory (" .. cwd .. ") is not in the allowed paths for Copilot",
            vim.log.levels.WARN,
            { title = "Utils.Copilot" }
        )
    end
end

---@param bufnr number
---@return boolean
function M.is_normal_buffer(bufnr)
    if vim.api.nvim_buf_is_valid(bufnr) then
        return vim.api.nvim_get_option_value("buftype", { buf = bufnr }) == "" and vim.fn.buflisted(bufnr) == 1
    end
    return false
end

---@param bufnr? number
---@return number?, number?
function M.get_win_with_normal_buffer(bufnr)
    if bufnr ~= nil and M.is_normal_buffer(bufnr) then
        return bufnr, vim.fn.bufwinid(bufnr)
    end
    -- local bufs = vim.fn.tabpagebuflist()
    local bufs = {}
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        bufs[vim.api.nvim_win_get_buf(win)] = win
        -- table.insert(bufs, vim.api.nvim_win_get_buf(win))
    end
    for buf, win in pairs(bufs) do
        if M.is_normal_buffer(buf) then
            return buf, win
        end
    end
    return nil, nil
end

---@param position? "left"|"right"
---@param close_on_leave? boolean
---@param callaback_on_leave? function(e: table, winid: integer, winnr: integer, bufnr: integer)
---@param callaback_on_close? function(e: table, winid: integer, winnr: integer, bufnr: integer)
---@param bufnr? number
function M.create_tool_window(
    title,
    position,
    close_on_leave,
    callback_before_entering,
    callaback_on_leave,
    callaback_on_close,
    bufnr
)
    position = position or "left"
    if close_on_leave == nil then
        close_on_leave = true
    end
    -- close_on_leave = close_on_leave ~= nil and close_on_leave or true
    local width = 45 -- TODO: do I need make it dynamic?
    local col, border
    if position == "left" then
        col = 0
        border = require("jb.borders").borders.tool_window.left
    elseif position == "right" then
        col = vim.o.columns - width
        border = require("jb.borders").borders.tool_window.right
    else
        error("Position must be either 'left' or 'right'")
    end
    local opts = {
        relative = "editor",
        width = width,
        height = vim.o.lines - (vim.o.cmdheight + 3),
        row = 0,
        col = col,
        zindex = 100,
        style = "minimal",
        border = border,
        title = title,
        title_pos = "left",
        -- Provides empty full-width footer to use its underline as border
        footer = string.rep(" ", width),
    }
    bufnr = (bufnr and vim.api.nvim_buf_is_valid(bufnr)) and bufnr or vim.api.nvim_create_buf(false, true)
    local winid = vim.api.nvim_open_win(bufnr, false, opts)
    local winnr = vim.api.nvim_win_get_number(winid)
    local bufnrs = { [bufnr] = true }
    vim.api.nvim_set_option_value(
        "winhl",
        "FloatTitle:ToolWindowFloatTitle," .. "FloatFooter:ToolWindowFloatFooter",
        { win = winid }
    )
    local close_tool_window = function()
        -- Requires delay to ensure the window is left
        vim.schedule(function()
            if vim.api.nvim_win_is_valid(winid) then
                vim.api.nvim_win_close(winid, true)
            end
        end)
    end
    local leave_tool_window = function(e)
        if type(callaback_on_leave) == "function" then
            callaback_on_leave(e, winid, winnr, bufnr)
        end
        if close_on_leave then
            close_tool_window()
        end
    end
    local group = vim.api.nvim_create_augroup("kdtsk-tool-window-" .. winid, { clear = true })
    vim.api.nvim_create_autocmd({ "WinLeave" }, {
        group = group,
        nested = true,
        callback = function(e)
            local ebuf_curr_winid = vim.fn.bufwinid(e.buf)
            if ebuf_curr_winid == winid then
                leave_tool_window(e)
            end
        end,
    })
    vim.api.nvim_create_autocmd("VimResized", {
        group = group,
        callback = function(e)
            vim.api.nvim_win_set_height(winid, vim.o.lines - (vim.o.cmdheight + 3))
        end,
    })
    vim.api.nvim_create_autocmd("WinClosed", {
        pattern = tostring(winid),
        group = group,
        callback = function(e)
            bufnrs[e.buf] = true
            vim.api.nvim_del_augroup_by_id(group)
            for nr, _ in pairs(bufnrs) do
                vim.api.nvim_buf_delete(nr, { force = true })
            end
            if type(callaback_on_close) == "function" then
                callaback_on_close(e, winid, winnr, bufnr)
            end
        end,
    })
    vim.api.nvim_create_autocmd({ "WinEnter", "TermEnter" }, {
        group = group,
        nested = true,
        callback = function(e)
            local ebuf_curr_winid = vim.fn.bufwinid(e.buf)
            if ebuf_curr_winid == winid then
                bufnrs[e.buf] = true
                for _, lhs in ipairs({ "<Esc>", "q", "<A-Esc>" }) do
                    vim.keymap.set("n", lhs, function()
                        if close_on_leave or lhs == "q" then
                            vim.api.nvim_win_close(winid, true)
                        end
                    end, { buffer = e.buf })
                end
            else
                -- Entering Terminal mode doesn't trigger WinLeave in previous window
                -- So it is tracked here to indicate WinLeave
                if e.event == "TermEnter" then
                    leave_tool_window(e)
                end
            end
        end,
    })
    if type(callback_before_entering) == "function" then
        callback_before_entering(winid, winnr, bufnr)
    end

    vim.schedule(function()
        vim.fn.win_gotoid(winid)
    end)

    return bufnr, winid, winnr
end

---@return nil|"pure"|"impure"|"unknown"
function M.nix_shell_type()
    local nix_shell = os.getenv("IN_NIX_SHELL")
    if nix_shell ~= nil then
        return nix_shell
    else
        local path = os.getenv("PATH") or ""
        if path:find("/nix/store", 1, true) then
            return "unknown"
        end
    end
    return nil
end

---@param nix_pkg string
---@param callback fun(cmd: table, output: table)
---@param flake string?
function M.cmd_via_nix(nix_pkg, command, callback, flake)
    flake = flake or "nixpkgs"
    local cmd = {}
    vim.system({ "nix", "path-info", "--impure", "--json", flake .. "#" .. nix_pkg }, { text = true }, function(o)
        if o.code == 0 then
            cmd = { "nix", "shell", "--impure", flake .. "#" .. nix_pkg, "--command", command }
            local function get_attr(attr, has_attr_callback)
                return vim.system(
                    { "nix", "eval", "--raw", flake .. "#" .. nix_pkg .. "." .. attr },
                    { text = true },
                    function(o_has_attr)
                        if o_has_attr.code == 0 then
                            has_attr_callback(o_has_attr.stdout)
                        else
                            has_attr_callback(nil)
                        end
                    end
                )
            end
            local attrs = {
                "meta.mainProgram", --[["pname"]]
            }
            local attr_ind = 1
            local function check_attr(val)
                if val == command then
                    cmd = { "nix", "run", "--impure", flake .. "#" .. nix_pkg, "--" }
                    vim.schedule(function()
                        callback(cmd, o)
                    end)
                elseif #attrs < attr_ind then
                    attr_ind = attr_ind + 1
                    get_attr(attrs[attr_ind], check_attr)
                else
                    vim.schedule(function()
                        callback(cmd, o)
                    end)
                end
            end
            get_attr(attrs[attr_ind], check_attr)
        else
            vim.notify(
                string.format("Did't find `%s` nix package due: %s", nix_pkg, o.stderr),
                vim.log.levels.WARN,
                { title = "Nix cmd" }
            )
            cmd = { command }
            vim.schedule(function()
                callback(cmd, o)
            end)
        end
        -- vim.schedule(function()
        --     callback(cmd, o)
        -- end)
    end)
end

---@param commands table<string, string|function|string[]>
---@param mason_mapping ?table<string, string>
---@return string[], table<string, string>, table<string, string>, table<string, string>
function M.handle_commands(commands, mason_mapping)
    mason_mapping = mason_mapping or {}
    local nix_path = vim.fn.exepath("nix")
    local has_msettings, msettings = pcall(require, "mason.settings")
    local mason_dir = nil
    if has_msettings then
        mason_dir = msettings.current.install_root_dir
    end

    local via_mason = {}
    local via_nix = {}
    local existing = {}
    local ignored = {}

    for name, command in pairs(commands) do
        command = type(command) == "function" and command() or command
        command = type(command) == "table" and command[1] or command
        assert(
            type(command) == "string" and command ~= "",
            "Command must be a non-empty string, but got: " .. vim.inspect(command)
        )

        local cmd_path = vim.fn.exepath(command --[[@as string]])

        if mason_dir ~= nil and mason_mapping[name] ~= nil and string.find(cmd_path, mason_dir) ~= nil then
            via_mason[#via_mason + 1] = name
        elseif #cmd_path ~= 0 then
            existing[name] = command
        elseif
            -- Handle via nix only if not in `nix shell` or `nix develop` environment
            -- because those environments are supposed to provide all the tooling
            #nix_path ~= 0 and M.nix_shell_type() == nil
        then
            via_nix[name] = command
        else
            ignored[name] = command
        end
    end

    return via_mason, via_nix, existing, ignored
end

--- Set up all language servers via this function
---@param name string
---@param cfg ?vim.lsp.ConfigLocal
function M.lsp_setup(name, cfg)
    cfg = cfg or {}

    -- Per language server config may turn off the server
    if cfg.enabled ~= false then
        vim.lsp.config(name, cfg)
        vim.lsp.enable(name)
    end
end

-- Debounce function to limit the rate at which a function can fire
function M.debounce(ms, fn)
    local timer = vim.uv.new_timer()
    return function(...)
        local argv = { ... }
        if timer ~= nil then
            timer:start(ms, 0, function()
                timer:stop()
                vim.schedule_wrap(fn)(unpack(argv))
            end)
        end
    end
end

function M.get_local_php_exe(executable)
    return M.find_executable({
        "vendor/bin/" .. executable,
        "vendor/bin/" .. executable .. ".phar",
        ".devenv/profile/bin/" .. executable,
    }, executable)
end

---@param env_var string
---@return string[] exclude_paths
function M.parse_exclude_env(env_var)
    local exclude_paths = {}

    -- Read environment variable
    local exclude_env = os.getenv(env_var)
    if exclude_env then
        -- Split by comma
        for pattern in exclude_env:gmatch("[^,]+") do
            table.insert(exclude_paths, pattern)
        end
    end

    return exclude_paths
end

---@param opts string
---@param arg string
---@param env_var string
---@param prepend_path? string
---@param after? boolean
function M.concat_exclude_ptrn(opts, arg, prepend_path, env_var, after)
    env_var = env_var or "FZFLUA_EXCLUDE"
    arg = arg or "--exclude"
    after = after ~= false -- Default to true if not explicitly set to false

    local exclude_paths = M.parse_exclude_env(env_var)

    local exclude_opts = ""
    -- Append --exclude options for each path
    for _, path in ipairs(exclude_paths) do
        exclude_opts = exclude_opts .. " " .. arg .. vim.fn.shellescape((prepend_path or "") .. path)
    end

    if not after then
        return exclude_opts .. " " .. opts
    else
        return opts .. exclude_opts
    end
end

---Checks if buffer modifiable, listed and not a special buffer
---@param buffer number
function M.should_track_buffer(buffer)
    local excluded_filetypes = { qf = true, help = true, NvimTree = true, fzf = true, netrw = true }
    -- Skip non-listed or non-loaded buffers
    if not vim.api.nvim_get_option_value("buflisted", { buf = buffer }) or not vim.api.nvim_buf_is_loaded(buffer) then
        return false
    end

    -- Skip non-modifiable buffers
    if not vim.api.nvim_get_option_value("modifiable", { buf = buffer }) then
        return false
    end

    -- Skip excluded filetypes
    local filetype = vim.api.nvim_get_option_value("filetype", { buf = buffer })
    if excluded_filetypes[filetype] then
        return false
    end

    return true
end

-- Update buffer_states and count modified buffers
 function M.count_modified_buffers()
    local unsaved = 0
    local new_unsaved = 0
    local new_buffers = 0
    local total_buffers = 0
    local cwd = vim.fn.getcwd()
    local buffers = vim.api.nvim_list_bufs()
    local new_buffer_states = {}

    for _, buffer in ipairs(buffers) do
        if M.should_track_buffer(buffer) then
            local is_modified = vim.api.nvim_get_option_value("modified", { buf = buffer })
            local filename = vim.api.nvim_buf_get_name(buffer)

            -- Only compute these values if we actually need them
            local is_empty_initial_buffer = false
            if not is_modified and filename ~= "" then
                local filename_resolved = vim.fn.resolve(filename)
                local line_count = vim.api.nvim_buf_line_count(buffer)
                is_empty_initial_buffer = (filename_resolved == cwd and line_count <= 1)
            end

            if not is_empty_initial_buffer then
                total_buffers = total_buffers + 1

                if is_modified then
                    if filename == "" then
                        -- Unnamed buffer that's been modified
                        new_unsaved = new_unsaved + 1
                    else
                        -- Existing file with unsaved changes
                        unsaved = unsaved + 1
                    end
                elseif filename ~= "" and not vim.loop.fs_stat(filename) then
                    -- Buffer has a name but file doesn't exist on disk yet
                    new_buffers = new_buffers + 1
                end

                -- Cache the state
                new_buffer_states[buffer] = {
                    modified = is_modified,
                    filename = filename,
                }
            end
        end
    end

    local buffer_states = new_buffer_states
    local buffer_modified_count = unsaved + new_unsaved + new_buffers
    return buffer_modified_count, buffer_states
end

return M

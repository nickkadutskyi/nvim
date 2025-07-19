---@class kdtsk.utils
---@field ui kdtsk.utils.ui
---@field lualine kdtsk.utils.lualine
---@field incline kdtsk.utils.incline
---@field icons kdtsk.utils.icons|jb.icons relies on jb.icons or blink.cmp
---@field lsp kdtsk.utils.lsp
---@field todo kdtsk.utils.todo
---@field fold kdtsk.utils.fold
---@field linter_phpmd kdtsk.utils.linter_phpmd
---@field php kdtsk.utils.php
---@field js kdtsk.utils.js
---@field tools kdtsk.utils.tools
---@field nix kdtsk.utils.nix
local M = {}

setmetatable(M, {
    __index = function(t, k)
        -- Tries to load `jb.icons` or icons from `blink.cmp`
        if k == "icons" then
            local has_jb_icons, jb_icons = pcall(require, "jb.icons")
            if has_jb_icons then
                t[k] = jb_icons
            else
                local has_blink, blink = pcall(require, "blik.cmp.config.appearance")
                if has_blink and blink.default.kind_icons then
                    t[k] = require("kdtsk.utils.icons")
                    t[k].kind = blink.default.kind_icons
                else
                    t[k] = require("kdtsk.utils.icons")
                end
            end
        else
            t[k] = require("kdtsk.utils." .. k)
        end

        return t[k]
    end,
})

---@type table<function>
local run_when_settings_loaded_functions = {}

---@param fn fun(settings: kdtsk.Settings): any?
---@return boolean, any -- Returns true if settings are already loaded, false otherwise
function M.run_when_settings_loaded(fn)
    assert(type(fn) == "function", "run_when_settings_loaded expects a function, but got: " .. type(fn))
    if vim.g.settings_loaded then
        return true, fn(vim.g.settings)
    else
        table.insert(run_when_settings_loaded_functions, fn)
        return false, nil
    end
end

vim.api.nvim_create_autocmd("User", {
    group = vim.api.nvim_create_augroup("kdtsk-settings-loaded", { clear = false }),
    pattern = "SettingsLoaded",
    callback = function()
        vim.g.settings_loaded = true
        for _, fn in ipairs(run_when_settings_loaded_functions) do
            if type(fn) == "function" then
                fn(vim.g.settings)
            else
                vim.notify("Expecting function but, got: " .. type(fn), vim.log.levels.WARN, { title = "kdtsk.utils" })
            end
        end
    end,
    once = true,
})

--- This extends a deeply nested list with a key in a table
--- that is a dot-separated string.
--- The nested list will be created if it does not exist.
---@generic T
---@param t T[]
---@param key string
---@param values T[]
---@return T[]?
function M.extend(t, key, values)
    local keys = vim.split(key, ".", { plain = true })
    for i = 1, #keys do
        local k = keys[i]
        t[k] = t[k] or {}
        if type(t) ~= "table" then
            return
        end
        t = t[k]
    end
    return vim.list_extend(t, values)
end

--- Gets a path to a package in the Mason registry.
--- Prefer this to `get_package`, since the package might not always be
--- available yet and trigger errors.
---@param pkg string
---@param path? string
---@param opts? { warn?: boolean }
function M.get_pkg_path(pkg, path, opts)
    pcall(require, "mason") -- make sure Mason is loaded. Will fail when generating docs
    local root = vim.env.MASON or (vim.fn.stdpath("data") .. "/mason")
    opts = opts or {}
    opts.warn = opts.warn == nil and true or opts.warn
    path = path or ""
    local ret = root .. "/packages/" .. pkg .. "/" .. path
    if opts.warn and not vim.loop.fs_stat(ret) and not require("lazy.core.config").headless() then
        vim.notify(
            ("Mason package path not found for **%s**:\n- `%s`\nYou may need to force update the package."):format(
                pkg,
                path
            ),
            vim.log.levels.WARN,
            {
                title = "Mason Package Path Not Found",
            }
        )
    end
    return ret
end

---@param fn fun()
---@param group? string|integer
function M.on_later(fn, group)
    -- If not using Lazy.nvim probably VimEnter will work
    vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = "VeryLazy",
        callback = function()
            fn()
        end,
    })
end

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
        "FloatTitle:ToolWindowFloatTitle,"
            .. "FloatFooter:ToolWindowFloatFooter,"
            .. "NormalFloat:ToolWindowFloatNormal",
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

---@param commands table<string, string|function|string[]>
---@return table<string, string>, table<string, string>, table<string, string>
function M.handle_commands(commands)
    local nix_path = vim.fn.exepath("nix")

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

        if #cmd_path ~= 0 then
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

    return via_nix, existing, ignored
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
---@param excluded_filetypes? table<string, boolean>
---@param include_filetypes? table<string, boolean>
function M.should_track_buffer(buffer, excluded_filetypes, include_filetypes)
    excluded_filetypes = excluded_filetypes or { qf = true, help = true, NvimTree = true, fzf = true, netrw = true }
    include_filetypes = include_filetypes or {}

    -- Skip non-listed or non-loaded buffers
    if not vim.api.nvim_get_option_value("buflisted", { buf = buffer }) or not vim.api.nvim_buf_is_loaded(buffer) then
        return false, "not listed"
    end

    -- Skip non-modifiable buffers
    if not vim.api.nvim_get_option_value("modifiable", { buf = buffer }) then
        return false, "not modifiable"
    end

    -- Check if included or skip excluded filetypes
    local filetype = vim.api.nvim_get_option_value("filetype", { buf = buffer })
    if excluded_filetypes[filetype] then
        return false, "excluded filetype: " .. filetype
    end

    if not vim.tbl_isempty(include_filetypes) then
        -- If include_filetypes is not empty, check if the filetype is in it
        if not include_filetypes[filetype] then
            return false,
                "not in include_filetypes: " .. filetype .. " (available: " .. vim.inspect(include_filetypes) .. ")"
        end
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

---@param arr string[]
function M.array_to_list(arr)
    local result = {}
    for _, str in ipairs(arr) do
        result[str] = true
    end
    return result
end

-- Queue for sequential system commands execution
local eval_queue = {}
local is_processing = false

---Process the next item in the queue
local function process_queue()
    if is_processing or #eval_queue == 0 then
        return
    end

    is_processing = true
    local item = table.remove(eval_queue, 1)

    vim.system(item.cmd, item.opts, function(o)
        is_processing = false
        item.callback(o)
        -- Process next item in queue
        vim.schedule(process_queue)
    end)
end

---Add system command to queue
---@param cmd table
---@param opts table
---@param callback function
function M.queue_command(cmd, opts, callback)
    table.insert(eval_queue, {
        cmd = cmd,
        opts = opts,
        callback = callback,
    })
    process_queue()
end

return M

local utils = require("ide.utils")
local pack = require("ide.pack")

--- MODULE DEFINITION ----------------------------------------------------------
---@class ide.Utils.Run
local M = {}
local I = {}

---@param fn function Callable to execute.
---@param error_prefix? string Optional prefix to prepend to error messages.
---@return boolean ok Whether the function executed successfully.
---@return any ... Results from the function call, or nil on error.
function M.now_res(fn, error_prefix)
    local ok, result = pcall(fn)
    if not ok then
        table.insert(I.cache.errors, "now_res:" .. (error_prefix or "") .. tostring(result))
        I.schedule()
        return ok, nil
    end
    I.schedule()
    return ok, result
end

---@param fn function Callable to execute.
---@param error_prefix? string Optional prefix to prepend to error messages.
function M.now(fn, error_prefix)
    local ok, err = pcall(fn)
    if not ok then
        table.insert(I.cache.errors, "now: " .. (error_prefix or "") .. tostring(err))
    end
    I.schedule()
end

---@param fn function Callable to execute.
---@param error_prefix? string Optional prefix to prepend to error messages.
function M.later(fn, error_prefix)
    table.insert(I.cache.queue, { fn = fn, error_prefix = "later: " .. (error_prefix and error_prefix or "") })
    I.schedule()
end

--- Executes the given function immediately if there are command-line arguments,
--- otherwise schedules it for later execution.
---@param fn function Callable to execute.
---@param error_prefix? string Optional prefix to prepend to error messages.
function M.now_if_arg_or_later(fn, error_prefix)
    if vim.fn.argc(-1) > 0 and not vim.g.ide_opened_dir then
        M.now_if_arg_or_later = M.now
    else
        M.now_if_arg_or_later = M.later
    end
    M.now_if_arg_or_later(fn, error_prefix)
end

--- Executes the given function immediately if there are command-line arguments,
--- otherwise schedules it to run on the "IdeDeferred" event.
---@param fn function Callable to execute.
---@param error_prefix? string Optional prefix to prepend to error messages.
function M.now_if_arg_or_deferred(fn, error_prefix)
    if vim.fn.argc(-1) > 0 and not vim.g.ide_opened_dir then
        M.now_if_arg_or_deferred = M.now
    else
        M.now_if_arg_or_deferred = M.on_deferred
    end
    M.now_if_arg_or_deferred(fn, error_prefix)
end

--- Schedules the given function to be executed on the "IdeDeferred" event.
---@param fn function Callable to execute.
---@param error_prefix? string Optional prefix to prepend to error messages.
function M.on_deferred(fn, error_prefix)
    utils.autocmd.create("IdeDeferred", {
        once = true,
        desc = "Run function on IdeDeferred event",
        callback = function()
            M.now(fn, "deferred: " .. (error_prefix and error_prefix or ""))
        end,
    })
end

---@param fn fun(bufnr: number, client?: vim.lsp.Client) Callable to execute with buffer number and LSP client data.
---@param error_prefix? string Optional prefix to prepend to error messages.
function M.on_lsp_attach(fn, error_prefix)
    utils.autocmd.create("LspAttach", {
        desc = "Run function on LspAttach event",
        group = "ide.lsp.attach",
        callback = function(e)
            local client = vim.lsp.get_client_by_id(e.data.client_id)
            M.now(function()
                fn(e.buf, client)
            end, "lsp_attach: " .. (error_prefix and error_prefix or ""))
        end,
    }, { clear = false })
end

--- Schedules the given function to be executed on the "IdeDone" event.
---@param name string Name of the plugin to match on the event data.
---@param fn function Callable to execute.
---@param error_prefix? string Optional prefix to prepend to error messages.
function M.on_load(name, fn, error_prefix)
    if pack.is_loaded(name) then
        M.now(function()
            fn(name)
        end, error_prefix)
    else
        local autocmdid
        autocmdid = utils.autocmd.create("PackLoad", {
            desc = "Run function on PackLoad event for plugin '" .. name .. "'",
            nested = true,
            callback = function(e)
                if e.data == name then
                    vim.api.nvim_del_autocmd(autocmdid)
                    M.now(function()
                        fn(name)
                    end, error_prefix)
                end
            end,
        })
    end
end

---Determines if a command can be run directly
---@param cmd string|function|table<string> Command to run
---@return boolean, string
function M.can_run_command(cmd)
    local command = type(cmd) == "function" and cmd() or cmd
    command = type(command) == "table" and command[1] or command
    assert(type(command) == "string" and command ~= "", "command must be a non-empty string, got: " .. vim.inspect(cmd))

    if vim.fn.executable(command) == 1 then
        return true, command
    end

    return false, command
end

function I.non_empty_str(v)
    return type(v) == "string" and v ~= ""
end

---@param opts {flake?: string, pkg: string, program: string}
---@param callback fun(cmd: table, output: table)
function M.get_nix_cmd(opts, callback)
    vim.validate("callback", callback, "function")
    vim.validate("opts.pkg", opts.pkg, I.non_empty_str, "non-empty-string")
    vim.validate("opts.program", opts.program, I.non_empty_str, "non-empty-string")
    vim.validate("opts.flake", opts.flake, I.non_empty_str, true, "non-empty-string")

    local flake = opts.flake or "nixpkgs"
    local cmd = { opts.program }

    -- nix eval flake output for a package and get pname and meta keys
    -- to check if it can do nix run (requires meta.mainProgram)
    M.queue_command({
        "nix",
        "eval",
        "--json",
        flake .. "#" .. opts.pkg,
        "--apply",
        "drv: { "
            .. 'pname = if builtins.hasAttr "pname" drv then drv.pname else "unknown"; '
            .. 'meta = if builtins.hasAttr "meta" drv then drv.meta else {}; '
            .. " }",
    }, {
        text = true,
        -- Timeout to avoid spawning nix processes in case if registry is not available
        -- timeout = 5000,
    }, function(o)
        if o.code == 0 then
            -- if found package then use `nix shell` which is slower than `nix run`
            -- but doesn't require `meta.mainProgram`
            cmd = { "nix", "shell", "--impure", flake .. "#" .. opts.pkg, "--command", opts.program }
            vim.schedule(function()
                -- check meta.mainProgram to see if we can use `nix run`
                local ok, pkg = pcall(vim.fn.json_decode, o.stdout)
                if ok then
                    if pkg.meta.mainProgram == opts.program then
                        cmd = { "nix", "run", "--impure", flake .. "#" .. opts.pkg, "--" }
                    end
                else
                    vim.notify(
                        "Failed to decode `" .. opts.pkg .. "` package's info: \n" .. o.stdout,
                        vim.log.levels.WARN,
                        { title = "ide.Utils.Run.get_nix_cmd" }
                    )
                end
                callback(cmd, o)
            end)
        else
            vim.notify(
                string.format("Didn't find `%s` package for `%s` cmd due to:\n%s", opts.pkg, opts.program, o.stderr),
                vim.log.levels.WARN,
                { title = "ide.Utils.Run.get_nix_cmd" }
            )
            vim.schedule(function()
                callback(cmd, o)
            end)
        end
    end)
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

--- INTERNAL DATA --------------------------------------------------------------
---Cache to track callables etc.
I.cache = {
    scheduled = false,
    ---@type {fn: function, error_prefix?: string}[]
    queue = {},
    errors = {},
}

--- INTERNAL FUNCTIONALITY -----------------------------------------------------
function I.schedule()
    if I.cache.scheduled then
        return
    end
    vim.schedule(I.run)
    I.cache.scheduled = true
end

function I.run()
    local timer, step_delay = assert(vim.loop.new_timer()), 1
    local fn
    fn = vim.schedule_wrap(function()
        local callback = I.cache.queue[1]
        if callback == nil then
            I.cache.scheduled, I.cache.queue = false, {}
            ---@diagnostic disable-next-line: need-check-nil
            timer:close()
            I.report()
            return
        end

        table.remove(I.cache.queue, 1)
        M.now(callback.fn, callback.error_prefix)
        timer:start(step_delay, 0, fn)
    end)
    ---@diagnostic disable-next-line: need-check-nil
    timer:start(step_delay, 0, fn)
end

function I.report()
    if #I.cache.errors == 0 then
        return
    end
    local error_lines = table.concat(I.cache.errors, "\n\n")
    I.cache.errors = {}
    I.notify("There were errors during run:\n\n" .. error_lines, "ERROR")
end

I.notify = vim.schedule_wrap(function(msg, level)
    level = level or "INFO"
    if type(msg) == "table" then
        msg = table.concat(msg, "\n")
    end
    vim.notify(string.format("(ide.utils.run) %s", msg), vim.log.levels[level], { title = "ide.utils.run" })
    vim.cmd("redraw")
end)

--- MODULE EXPORT --------------------------------------------------------------
return M

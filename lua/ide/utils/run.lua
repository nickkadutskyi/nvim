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
        table.insert(I.cache.errors, (error_prefix or "") .. tostring(result))
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
        table.insert(I.cache.errors, (error_prefix or "") .. tostring(err))
    end
    I.schedule()
end

---@param fn function Callable to execute.
---@param error_prefix? string Optional prefix to prepend to error messages.
function M.later(fn, error_prefix)
    table.insert(I.cache.queue, { fn = fn, error_prefix = error_prefix })
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
            M.now(fn, error_prefix)
        end,
    })
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

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
    local timer, step_delay = vim.loop.new_timer(), 1
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
        ---@diagnostic disable-next-line: need-check-nil
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

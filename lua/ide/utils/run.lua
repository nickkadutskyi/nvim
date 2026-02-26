--- MODULE DEFINITION ----------------------------------------------------------
---@class ide.Utils.Run
local M = {}
local I = {}

---@param fn function Callable to execute.
function M.now(fn)
    local ok, err = pcall(fn)
    if not ok then
        table.insert(I.cache.errors, err)
    end
    I.schedule()
end

---@param fn function Callable to execute.
function M.later(fn)
    table.insert(I.cache.queue, fn)
    I.schedule()
end

--- INTERNAL DATA --------------------------------------------------------------
---Cache to track callables etc.
I.cache = {
    scheduled = false,
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
    local fn = nil
    fn = vim.schedule_wrap(function()
        local callback = I.cache.queue[1]
        if callback == nil then
            I.cache.scheduled, I.cache.queue = false, {}
            I.report()
            return
        end

        table.remove(I.cache.queue, 1)
        M.now(callback)
        timer:start(step_delay, 0, fn)
    end)
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

--- MODULE EXPORT --------------------------------------------------------------
return M

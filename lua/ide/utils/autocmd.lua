---@class ide.Utils.Autocmd
local M = {}
local I = {}

---@param event string|string[] event(s) to trigger autocmd
---@param opts vim.api.keyset.create_autocmd
---@param group_opts? vim.api.keyset.create_augroup
---@return integer|false # autocmd id(s)
function M.create(event, opts, group_opts)
    local resolved = I.resolve_events(event)

    if #resolved == 0 then
        vim.notify(
            "No valid events resolved from input: " .. vim.inspect(event),
            vim.log.levels.WARN,
            { title = "ide.Utils.Autocmd.create()" }
        )
        return false
    end

    local event_names = {}
    local resolved_patterns = {}

    -- Collect event names from resolved definitions
    for _, r in ipairs(resolved) do
        table.insert(event_names, r.event)
        if r.pattern then
            table.insert(resolved_patterns, r.pattern)
        end
    end

    vim.validate("ide.utils.autocmd.create.event_names", event_names, function(value)
        return type(value) == "table" and #value > 0
    end, "non-empty list of event names")

    -- Combine resolved patterns with any patterns provided in opts
    if #resolved_patterns > 0 then
        local existing = opts.pattern
        if existing then
            if type(existing) == "string" then
                table.insert(resolved_patterns, existing)
            elseif type(existing) == "table" then
                for _, p in ipairs(existing) do
                    table.insert(resolved_patterns, p)
                end
            end
        end
        opts.pattern = resolved_patterns
    end

    group_opts = group_opts or {}
    group_opts.clear = group_opts.clear or false

    if not opts.group then
        opts.group = vim.api.nvim_create_augroup("ide.utils.autocmd", { clear = false })
    end
    if type(opts.group) == "string" then
        ---@diagnostic disable-next-line: param-type-mismatch
        opts.group = vim.api.nvim_create_augroup(opts.group, group_opts)
    end

    opts.desc = opts.desc or "ide.utils autocmd"

    return vim.api.nvim_create_autocmd(event_names, opts)
end

--- INTERNAL DATA --------------------------------------------------------------

-- Defines custom events
---@class (exact) Dictionary<Event>: { [Event]: {event: "User", pattern: Event} }
---@type Dictionary<ide.events>
I.events = {}
I.events.IdeLater = { event = "User", pattern = "IdeLater" }

--- INTERNAL FUNCTIONS ---------------------------------------------------------

---@param event string|string[] event name(s) or custom event key(s) to resolve
---@return table<{ event: string, pattern?: string }> resolved event definitions
function I.resolve_events(event)
    if type(event) == "string" then
        local resolved = I.events[event] or { event = event }
        return { resolved }
    elseif type(event) == "table" then
        local events = {}
        for _, e in ipairs(event) do
            local resolved = I.resolve_events(e)
            for _, r in ipairs(resolved) do
                events[#events + 1] = r
            end
        end
        return events
    else
        error("ide.utils.autocmd: Invalid event type: " .. type(event))
    end
end
return M

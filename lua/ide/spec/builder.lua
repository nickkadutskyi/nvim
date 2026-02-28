--- MODULE DEFINITION ----------------------------------------------------------

---@class ide.Spec.Builder
local M = {}
local I = {}

---@type string[] insertion order
I.order = {}
---@type table<string, ide.Spec.Builder.Entry>
I.registry = {}

---@param spec vim.pack.Spec|vim.pack.Spec[]|ide.SpecData.Named|ide.SpecData.Named[]
function M.add(spec)
    vim.validate("spec", spec, "table")
    if type(spec[1]) == "table" then
        for _, s in ipairs(spec) do
            M.add(s --[[@as vim.pack.Spec|ide.SpecData.Named]])
        end
        return
    end

    local name = I.name(spec)

    if not I.registry[name] then
        I.registry[name] = { spec = nil, data_fragments = {} }
        table.insert(I.order, name)
    end

    local entry = I.registry[name]

    if spec.src then
        entry.spec = {
            src = spec.src,
            name = name,
            version = spec.version,
        }
    end

    if type(spec[1]) == "string" then
        table.insert(entry.data_fragments, spec)
    elseif spec.data ~= nil then
        table.insert(entry.data_fragments, spec.data)
    end
end

--- Merge all collected specs. Call once, pass result to vim.pack.add().
---@return vim.pack.Spec[]
function M.get_specs()
    local result = {}
    for _, name in ipairs(I.order) do
        local entry = I.registry[name]
        if not entry.spec then
            vim.notify("ide.spec.builder: no src for '" .. name .. "'", vim.log.levels.WARN)
        else
            entry.spec.data = I.merge_data_fragments(entry.data_fragments)
            if entry.spec.data.enabled ~= false then
                table.insert(result, entry.spec)
            end
        end
    end
    return result
end

--- Resolve opts chain at load time (called from on_load after packadd right before before hook).
---@param spec vim.pack.Spec
---@return table
function M.resolve_opts(spec)
    local data = spec.data or {}
    local chain = data.opts_chain or {}
    local extend_paths = data.opts_extend or {}
    local opts = {}

    for _, item in ipairs(chain) do
        if type(item) == "table" then
            -- save the lists we need to extend before merge replaces them
            local saved = {}
            for _, key in ipairs(extend_paths) do
                local path = vim.split(key, ".", { plain = true })
                local old = vim.tbl_get(opts, unpack(path))
                local new = vim.tbl_get(item, unpack(path))
                if type(old) == "table" and type(new) == "table" then
                    saved[key] = { path = path, list = vim.list_extend(vim.list_extend({}, old), new) }
                end
            end
            opts = vim.tbl_deep_extend("force", opts, item)
            -- restore extended lists (overwrite what deep_extend replaced)
            for _, entry in pairs(saved) do
                local t = opts
                for i = 1, #entry.path - 1 do
                    t = t[entry.path[i]]
                end
                t[entry.path[#entry.path]] = entry.list
            end
        else
            opts = item(spec, opts) or opts
        end
    end

    return opts
end

--- INTERNAL FUNCTIONS ---------------------------------------------------------

function I.is_nonempty_string(x)
    return type(x) == "string" and x ~= ""
end

---@param spec vim.pack.Spec|ide.SpecData.Named
---@return string
function I.name(spec)
    vim.validate("spec", spec, "table")
    local name
    if type(spec[1]) == "string" then
        name = spec[1]
    else
        vim.validate("spec.src", spec.src, I.is_nonempty_string, false, "non-empty string")
        name = spec.name or spec.src:gsub("%.git$", "")
    end
    name = (type(name) == "string" and name or ""):match("[^/]+$") or ""
    vim.validate("spec.name", name, I.is_nonempty_string, true, "non-empty string")

    return name
end

---Merges a list of data fragments into a single data table
---
---@param fragments ide.SpecData[] list of data fragments to merge, in order of application (later entries override earlier ones)
---@return ide.SpecData.OptsChained -- merged data with an `opts_chain`
function I.merge_data_fragments(fragments)
    vim.validate("spec", fragments, "table")

    local result = { opts_chain = {}, opts_extend = {} }
    local extend_seen = {}

    for _, data in ipairs(fragments) do
        if data.enabled == false then
            result.enabled = false
        end
        if data.opts ~= nil then
            table.insert(result.opts_chain, data.opts)
        end
        if data.before ~= nil then
            result.before = data.before
        end
        if data.after ~= nil then
            result.after = data.after
        end
        if data.build ~= nil then
            result.build = data.build
        end
        for _, key in ipairs(data.opts_extend or {}) do
            if not extend_seen[key] then
                extend_seen[key] = true
                table.insert(result.opts_extend, key)
            end
        end
    end
    return result
end

return M

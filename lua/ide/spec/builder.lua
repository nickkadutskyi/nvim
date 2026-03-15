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

    -- check if spec is empty (e.g. empty table or empty list) and ignore it if so
    if next(spec) == nil then
        return
    end

    -- if the first element is a table, we assume it's a list of specs and
    -- add them all (this allows for convenient grouping of related specs in the input)
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
                -- HACK: Clear spec's opts_chain to avoid issue with mixed tables
                --       See https://github.com/neovim/neovim/issues/35550
                if I.has_mixed_table(entry.spec.data.opts_chain) then
                    local spec = vim.deepcopy(entry.spec)
                    if spec then
                        -- Clearing opts_chain to avoid issues when passed to
                        -- autocmd data field (in case of PackChanged and PackChangedPre).
                        -- We will get opts_chain from registry
                        spec.data.opts_chain = nil
                        table.insert(result, spec)
                    else
                        vim.notify(
                            "Failed to deepcopy spec for '" .. name .. "'",
                            vim.log.levels.WARN,
                            { title = "ide.spec.builder.get_specs()" }
                        )
                        table.insert(result, entry.spec)
                    end
                else
                    table.insert(result, entry.spec)
                end
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
    -- HACK: we check in registry also because for some plugin specs we delete `opts_chain`
    --       in case where opts can have mixed table with both index and keyed items
    --       which casuse issue when passed to autocmd data field (in case of PackChanged and PackChangedPre).
    --       See https://github.com/neovim/neovim/issues/35550
    --       See https://github.com/neovim/neovim/issues/36638
    local chain = data.opts_chain or I.registry[spec.name].spec.data.opts_chain or {}
    local extend_paths = data.opts_extend or {}
    local opts = {}

    for _, item in ipairs(chain) do
        if type(item) == "table" then
            -- save the lists we need to extend before merge replaces them
            local saved = {}
            for _, key in ipairs(extend_paths) do
                local path = vim.iter(vim.split(key, ".", { plain = true }))
                    :map(function(v)
                        if v:match("^[\"']%d+[\"']$") then
                            return v:sub(2, -2)
                        elseif v:match("^%d+$") then
                            return tonumber(v)
                        end
                        return v
                    end)
                    :totable()
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

function I.has_mixed_table(tb)
    if type(tb) ~= "table" then
        return false
    end
    local has_sequential = false
    local has_keyed = false
    for k, v in pairs(tb) do
        if type(k) == "number" and k >= 1 and math.floor(k) == k then
            has_sequential = true
        else
            has_keyed = true
        end
        if has_sequential and has_keyed then
            return true
        end
        if type(v) == "table" and I.has_mixed_table(v) then
            return true
        end
    end
    return false
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
        if data.dev ~= nil then
            result.dev = data.dev
        end
        if data.cond ~= nil then
            result.cond = data.cond
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
        if data.event ~= nil then
            local event = type(data.event) == "string" and { data.event } or data.event
            result.event = vim.iter({ result.event or {}, event })
                :flatten()
                :filter(function(e)
                    return type(e) == "string" and e ~= ""
                end)
                :totable()
        end
        if data.ft ~= nil then
            local ft = type(data.ft) == "string" and { data.ft } or data.ft
            result.ft = vim.iter({ result.ft or {}, ft })
                :flatten()
                :filter(function(f)
                    return type(f) == "string" and f ~= ""
                end)
                :totable()
        end
        if data.keys ~= nil then
            result.keys = result.keys or {}
            vim.list_extend(result.keys, data.keys)
        end
        if data.deferred ~= nil then
            result.deferred = data.deferred
        end
    end

    return result
end

return M

local utils = require("ide.utils")
local spec_builder = require("ide.spec.builder")

--- MODULE DEFINITION ----------------------------------------------------------
local M = {}
local I = {}

--- Track which plugins have been loaded to prevent double-loading across triggers.
---@type table<string, boolean>
I.loaded = {}

function M.is_loaded(name)
    return I.loaded[name] == true
end

---@param specs vim.pack.Spec[]
function M.load(specs)
    -- Dev phase: rewrite spec.src to local path where applicable
    for _, spec in ipairs(specs) do
        local dev_path = require("ide.dev").resolve(spec)
        if dev_path then
            spec.src = dev_path
        end
    end

    -- Pre-load phase: run before hooks for all plugins (mirrors lazy.nvim init)
    for _, spec in ipairs(specs) do
        local data = spec.data or {}
        if type(data.before) == "function" then
            utils.run.now(function()
                data.before({ spec = spec, path = "" })
            end, "ide.pack: before hook failed for '" .. (spec.name or "?") .. "' due to: ")
        end
    end

    -- Autocmd before plugins are loaded
    vim.api.nvim_exec_autocmds("User", { pattern = "PackBefore", modeline = false })

    I.create_autocmds()

    -- Install and load plugins, running after hooks in on_load
    vim.pack.add(specs, { load = I.on_load, confirm = true })
end

--- Get all active plugins whose spec.src is a local filesystem path (not a URL).
---@return vim.pack.PlugData[]
function M.get_local_plugins()
    return vim.iter(vim.pack.get())
        :filter(function(p)
            if not p.active or not p.spec.src then
                return false
            end
            local src = p.spec.src
            -- A URL starts with a scheme like https:// or git@; a local path does not.
            return vim.fn.isdirectory(src) == 1 or (not src:match("^%w+://") and not src:match("^%w+@"))
        end)
        :totable()
end

--- Get names of all local plugins.
---@return string[]
function M.get_local_plugin_names()
    return vim.iter(M.get_local_plugins())
        :map(function(p)
            return p.spec.name
        end)
        :totable()
end

--- INTERNAL FUNCTIONS ---------------------------------------------------------

---@param plugin_data {spec: vim.pack.Spec, path: string}
function I.on_load(plugin_data)
    local spec = plugin_data.spec
    local data = spec.data or {}
    local name = spec.name or "?"

    -- Check `cond` field to determine whether to load plugin
    if type(data.cond) == "function" then
        local ok, result = utils.run.now_res(function()
            return data.cond(plugin_data)
        end, "ide.pack: cond function failed for '" .. name .. "' due to: ")
        data.cond = ok and result or false
    end
    if data.cond == false then
        return
    end

    -- deferred defaults to true; setting to false disables all lazy loading.
    local deferred = data.deferred ~= false

    local deferred_load = false

    -- Event trigger (only when deferred)
    if deferred and data.event then
        deferred_load = false
            ~= utils.autocmd.create(data.event, {
                once = true,
                desc = "ide.pack: Load plugin '" .. name .. "' on event(s).",
                callback = function()
                    if not I.loaded[name] then
                        I.loaded[name] = true
                        I.load_plugin(plugin_data)
                    end
                end,
            })
    end

    -- Filetype trigger (only when deferred)
    if deferred and data.ft and #data.ft > 0 then
        deferred_load = false
            ~= utils.autocmd.create("FileType", {
                once = true,
                pattern = data.ft,
                desc = "ide.pack: Load plugin '" .. name .. "' on filetype(s).",
                callback = function()
                    if not I.loaded[name] then
                        I.loaded[name] = true
                        I.load_plugin(plugin_data)
                    end
                end,
            })
    end

    -- Keys trigger (only when deferred)
    if deferred and data.keys and #data.keys > 0 then
        deferred_load = true
        for _, key in ipairs(data.keys) do
            I.set_placeholder_key(key, plugin_data)
        end
    end

    if not deferred_load then
        I.loaded[name] = true
        I.load_plugin(plugin_data)
    end
end

---@param plugin_data {spec: vim.pack.Spec, path: string}
function I.load_plugin(plugin_data)
    local spec = plugin_data.spec
    local data = spec.data or {}

    -- Remove placeholder keymaps and register real keymaps from keys field.
    -- Done before packadd so re-fed keys hit the real mapping when the plugin loads.
    if data.keys then
        for _, key in ipairs(data.keys) do
            local lhss = type(key.lhs) == "string" and { key.lhs } or key.lhs
            lhss = vim.iter(lhss)
                :filter(function(lhs)
                    return type(lhs) == "string"
                end)
                :totable()
            for _, lhs in ipairs(lhss) do
                local modes = I.resolve_modes(key.mode)
                for _, mode in ipairs(modes) do
                    pcall(vim.keymap.del, mode, lhs)
                end
                if key.rhs ~= nil then
                    vim.keymap.set(modes, lhs, key.rhs, I.key_to_opts(key))
                end
            end
        end
    end

    -- Loads similarly to vim.pack.add with `load` not specified
    vim.cmd.packadd({ vim.fn.escape(spec.name, " "), bang = vim.v.vim_did_enter == 0, magic = { file = false } })
    -- Source after/plugin/ when loading after startup (packadd never does this)
    if vim.v.vim_did_enter == 1 then
        local after_paths = vim.fn.glob(plugin_data.path .. "/after/plugin/**/*.{vim,lua}", false, true)
        for _, path in ipairs(after_paths) do
            vim.cmd.source({ path, magic = { file = false } })
        end
    end

    -- Run after hook if defined, passing resolved opts
    if data.after or (data.opts_chain and #data.opts_chain > 0) then
        I.after(plugin_data)
    end

    vim.api.nvim_exec_autocmds("User", { pattern = "PackLoad", modeline = false, data = spec.name })
end

function I.after(plugin_data)
    local spec = plugin_data.spec
    local data = spec.data or {}

    if type(data.after) == "function" then
        local opts = spec_builder.resolve_opts(spec)
        utils.run.now(function()
            data.after(plugin_data, opts)
        end, "ide.pack: after hook failed for '" .. (spec.name or "?") .. "' due to: ")
    else
        -- TODO: try to find main module from spec.scr and run its setup()
    end
end

--- Register a placeholder keymap that loads the plugin on first press then re-fires the key.
---@param key ide.SpecData.Key
---@param plugin_data vim.pack.PluginData
function I.set_placeholder_key(key, plugin_data)
    local spec = plugin_data.spec
    local name = spec.name or "?"

    local lhss = type(key.lhs) == "string" and { key.lhs } or key.lhs
    lhss = vim.iter(lhss)
        :filter(function(lhs)
            return type(lhs) == "string"
        end)
        :totable()

    for _, lhs in ipairs(lhss) do
        local modes = I.resolve_modes(key.mode)
        for _, mode in ipairs(modes) do
            local opts = I.key_to_opts(key)
            opts.desc = opts.desc or ("ide.pack: Load '" .. name .. "' on key")
            vim.keymap.set(mode, lhs, function()
                if not I.loaded[name] then
                    I.loaded[name] = true
                    I.load_plugin(plugin_data)
                end
                -- Re-feed so the real mapping (set in load_plugin or the after hook) handles it.
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(lhs, true, false, true), "m", false)
            end, opts)
        end
    end
end

--- Normalise a mode value from a key spec into a list of mode strings.
---@param mode string|string[]|nil
---@return string[]
function I.resolve_modes(mode)
    if type(mode) == "table" then
        return mode
    elseif type(mode) == "string" then
        return { mode }
    else
        return { "n" }
    end
end

--- Strip positional and mode fields from a key spec, returning only keymap opts.
---@param key ide.SpecData.Key
---@return vim.keymap.set.Opts
function I.key_to_opts(key)
    local opts = {}
    for k, v in pairs(key) do
        if k ~= "lhs" and k ~= "rhs" and k ~= "mode" then
            opts[k] = v
        end
    end
    return opts
end

--- Create autocmds for plugin management, such as running build hooks after install/update
function I.create_autocmds()
    utils.autocmd.create("PackChanged", {
        desc = "ide.pack: Runs build hook after plugin install/update",
        callback = function(e)
            local data = e.data --[[@as settings.PackEvent]]
            -- Run build function if plugin is installed/updated and has a build function
            if
                data
                and data.active
                and (data.kind == "install" or data.kind == "update")
                and data.spec
                and data.spec.data
                and type(data.spec.data.build) == "function"
            then
                utils.run.now(function()
                    data.spec.data.build(data)
                end, "ide.pack: build hook failed for '" .. (data.spec.name or "?") .. "' due to: ")
            end
        end,
    })
end

return M

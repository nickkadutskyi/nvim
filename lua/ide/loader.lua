--- Plugin loader that replicates lazy.nvim's multi-module opts composition
--- for vim.pack-managed plugins.
---
--- Usage (in any module):
---   local loader = require("ide.loader")
---   loader.add({
---     {
---       src = "neovim/nvim-lspconfig",   -- only needed in the defining module
---       opts = { servers = {} },
---       config = function(_, opts) ... end,
---     },
---     {
---       name = "nvim-lspconfig",          -- patch from another module (no src)
---       opts = function(_, opts)
---         opts.servers["lua_ls"] = { settings = { Lua = {} } }
---       end,
---     },
---   })
---
--- Usage (in settings.plugins on_load):
---   loader.setup(plugin_data)  -- merges opts chain, calls config

--- Extended spec (superset of vim.pack.Spec).
--- src/name/version/data go to vim.pack; opts/config are handled by the loader.
---@class ide.Spec
---@field src? string "user/repo" path – required when registering the plugin source
---@field name? string Plugin name; derived from the last segment of src when omitted
---@field version? string Commit hash or tag to pin
---@field data? ide.SpecData Extra data forwarded to vim.pack (build, enabled…)
---@field opts? table | fun(plugin: {spec: vim.pack.Spec, path: string}, opts: table): table?
---@field config? fun(plugin: {spec: vim.pack.Spec, path: string}, opts: table)

---@class ide.loader.Entry
---@field chain (table | fun(plugin: table, opts: table): table?)[]
---@field config? fun(plugin: table, opts: table)

--- MODULE DEFINITION -----------------------------------------------------------

---@class ide.Loader
local M = {}
local I = {}

--- vim.pack specs collected from M.add() calls; pass to vim.pack.add().
---@type vim.pack.Spec[]
M.specs = {}

---@type table<string, ide.loader.Entry>
I.registry = {}

--- INTERNAL FUNCTIONS ----------------------------------------------------------

---@param spec ide.Spec
---@return string
function I.name(spec)
    if spec.name then
        return spec.name
    end
    if spec.src then
        return spec.src:match("[^/]+$") --[[@as string]]
    end
    error("ide.loader: spec must have 'src' or 'name'\n" .. vim.inspect(spec))
end

--- MODULE FUNCTIONS ------------------------------------------------------------

--- Add plugin specs from a module. Can be called multiple times from different
--- modules. Specs sharing the same name are merged in registration order:
---   - opts tables  → accumulated via vim.tbl_deep_extend("force", …)
---   - opts functions → chained; mutate opts in-place or return a replacement
---   - config        → replaced (last definition wins)
---@param specs ide.Spec[]
function M.add(specs)
    for _, spec in ipairs(specs) do
        local name = I.name(spec)

        -- Collect vim.pack.Spec only when the source is being defined
        if spec.src then
            table.insert(M.specs, {
                src = spec.src,
                name = name,
                version = spec.version,
                data = spec.data,
            })
        end

        if not I.registry[name] then
            I.registry[name] = { chain = {}, config = nil }
        end

        local entry = I.registry[name]

        if spec.opts ~= nil then
            table.insert(entry.chain, spec.opts)
        end

        if spec.config ~= nil then
            entry.config = spec.config
        end
    end
end

--- Resolve the merged opts and config for a plugin name.
--- Opts tables are deep-merged; opts functions are called with the accumulated
--- opts as the second argument (matching lazy.nvim's `function(_, opts)` style).
--- A function's return value replaces opts when non-nil; otherwise mutation
--- is assumed (same behaviour as lazy.nvim).
---@param name string
---@param plugin_data? {spec: vim.pack.Spec, path: string}
---@return table opts, fun(plugin: table, opts: table)? config
function M.resolve(name, plugin_data)
    local entry = I.registry[name]
    if not entry then
        return {}, nil
    end

    local opts = {}

    for _, item in ipairs(entry.chain) do
        if type(item) == "table" then
            opts = vim.tbl_deep_extend("force", opts, item)
        else
            -- item is a function: call(plugin_data, accumulated_opts)
            local result = item(plugin_data, opts)
            if result ~= nil then
                opts = result
            end
        end
    end

    return opts, entry.config
end

--- Run setup for a loaded plugin: resolve the merged opts and call config.
--- Designed to be called from the vim.pack on_load callback after packadd.
---@param plugin_data {spec: vim.pack.Spec, path: string}
function M.setup(plugin_data)
    local name = plugin_data.spec.name
    local opts, config_fn = M.resolve(name, plugin_data)
    if config_fn then
        config_fn(plugin_data, opts)
    end
end

return M

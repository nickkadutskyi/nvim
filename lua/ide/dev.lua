local utils = require("ide.utils")

--- MODULE DEFINITION ----------------------------------------------------------

---@class ide.Dev
local M = {}
local I = {}

---@type ide.Dev.Config
I.config = {
    path = "~/Documents",
    patterns = {},
    fallback = true,
}

I.installed = {}

--- Configure the dev loader. Call before ide.spec.builder.add() calls are made.
---@param opts? ide.Dev.Config
function M.setup(opts)
    if opts then
        vim.validate("opts", opts, "table")
        I.config = vim.tbl_deep_extend("force", I.config, opts)
    end
    I.config.path = vim.fn.expand(I.config.path)
end

--- Resolve a local dev directory for a spec.
--- Returns the local path string when dev mode applies, or nil to keep spec.src.
---@param spec vim.pack.Spec
---@return string|nil
function M.resolve(spec)
    local data = spec.data or {}
    local is_dev = data.dev

    -- Auto-detect via patterns when dev is not explicitly set
    if is_dev == nil and spec.src then
        for _, pattern in ipairs(I.config.patterns) do
            if spec.src:find(pattern, 1, true) then
                is_dev = true
                break
            end
        end
    end

    if not is_dev then
        return nil
    end

    -- Build the local directory path
    local dev_dir = I.config.path .. "/" .. spec.name

    -- Fallback: revert to remote if the local directory does not exist
    if I.config.fallback and vim.fn.isdirectory(dev_dir) ~= 1 then
        return nil
    end

    return dev_dir
end

---@param specs vim.pack.Spec[]
---@param opts {load: fun(plugin_dat: {spec: vim.pack.Spec, path: string})}
function M.add(specs, opts)
    vim.validate("specs", specs, vim.islist, false, "list")
    opts = vim.tbl_extend("force", { load = vim.v.vim_did_init == 1, confirm = true }, opts or {})
    vim.validate("opts", opts, "table")

    local plug_dir = I.get_plug_dir()

    if #I.installed == 0 then
        I.prepare_install_dir(plug_dir)
    end

    local plugs = {} --- @type ide.pack.Plug[]
    for i = 1, #specs do
        local p = I.new_plug(specs[i], plug_dir)
        plugs[i] = p
    end

    -- Create symlinks for each plugin and track them
    for _, plug in ipairs(plugs) do
        local target = plug.info.dev_path
        local link_path = vim.fs.joinpath(plug_dir, plug.spec.data.dev_name or plug.spec.name)

        if target then
            -- Remove existing entry if it exists (stale symlink, dir, etc.)
            if vim.uv.fs_lstat(link_path) then
                vim.fn.delete(link_path, "rf")
            end

            vim.uv.fs_symlink(target, link_path)
            I.installed[plug.spec.name] = true

            if opts.load then
                opts.load({ spec = plug.spec, path = link_path })
            end
        end
    end
end

function I.prepare_install_dir(plugin_dir)
    local plug_dir = I.get_plug_dir()
    if vim.uv.fs_lstat(plug_dir) then
        vim.fn.delete(plug_dir, "rf")
    end
    vim.fn.mkdir(plug_dir, "p")
end

--- @return string
function I.get_plug_dir()
    return vim.fs.joinpath(vim.fn.stdpath("data"), "site", "pack", "dev", "opt")
end

--- @class (private) ide.pack.Plug
--- @field spec vim.pack.SpecResolved
--- @field path string
--- @field info ide.pack.PlugInfo Gathered information about plugin.
---
--- @class (private) ide.pack.PlugInfo
--- @field dev_path? string

--- @param spec vim.pack.Spec
--- @param plug_dir string?
--- @return ide.pack.Plug
function I.new_plug(spec, plug_dir)
    local spec_resolved = I.normalize_spec(spec)
    local path = vim.fs.joinpath(plug_dir or I.get_plug_dir(), spec_resolved.data.dev_name or spec_resolved.name)
    local info = { dev_path = M.resolve(spec) }
    return { spec = spec_resolved, path = path, info = info }
end

function I.is_nonempty_string(x)
    return type(x) == "string" and x ~= ""
end

--- @param spec string|vim.pack.Spec
--- @return vim.pack.SpecResolved
function I.normalize_spec(spec)
    vim.validate("spec", spec, "table")
    vim.validate("spec.src", spec.src, I.is_nonempty_string, false, "non-empty string")
    local name = spec.name or spec.src:gsub("%.git$", "")
    name = (type(name) == "string" and name or ""):match("[^/]+$") or ""
    vim.validate("spec.name", name, I.is_nonempty_string, true, "non-empty string")
    spec.data = spec.data or {}
    spec.data.dev_name = "dev-" .. name
    return { src = spec.src, name = name, version = spec.version, data = spec.data }
end

return M

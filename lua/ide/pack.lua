local utils = require("ide.utils")
local spec_builder = require("ide.spec.builder")

--- MODULE DEFINITION ----------------------------------------------------------
local M = {}
local I = {}

---@param specs vim.pack.Spec[]
function M.load(specs)
    -- Pre-load phase: run before hooks for all plugins (mirrors lazy.nvim init)
    for _, spec in ipairs(specs) do
        local data = spec.data or {}
        if type(data.before) == "function" then
            utils.run.now(function()
                data.before({ spec = spec, path = "" })
            end, "ide.pack: before hook failed for '" .. (spec.name or "?") .. "' due to: ")
        end
    end

    I.create_autocmds()

    -- Install and load plugins, running after hooks in on_load
    vim.pack.add(specs, { load = I.on_load, confirm = true })
end

--- INTERNAL FUNCTIONS ---------------------------------------------------------

---@param plugin_data {spec: vim.pack.Spec, path: string}
function I.on_load(plugin_data)
    local spec = plugin_data.spec
    local data = spec.data or {}

    -- Check `cond` field to determine whether to load plugin
    if type(data.cond) == "function" then
        local ok, result = utils.run.now_res(function()
            return data.cond(plugin_data)
        end, "ide.pack: cond function failed for '" .. (spec.name or "?") .. "' due to: ")
        data.cond = ok and result or false
    end
    if data.cond == false then
        return
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
    if type(data.after) == "function" then
        local opts = spec_builder.resolve_opts(spec)
        utils.run.now(function()
            data.after(plugin_data, opts)
        end, "ide.pack: after hook failed for '" .. (spec.name or "?") .. "' due to: ")
    end
end

--- Create autocmds for plugin management, such as running build hooks after install/update
function I.create_autocmds()
    local group = vim.api.nvim_create_augroup("ide.pack", { clear = true })

    vim.api.nvim_create_autocmd("PackChanged", {
        group = group,
        ---@param e vim.api.keyset.create_autocmd.callback_args
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
        desc = "Runs build hook after plugin install/update",
    })
end

return M

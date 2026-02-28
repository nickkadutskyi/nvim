local utils = require("ide.utils")

--- Define custom autocmds
utils.autocmd.create("UIEnter", {
    once = true,
    callback = function()
        utils.run.later(function()
            vim.api.nvim_exec_autocmds("User", { pattern = "IdeLater", modeline = false })
        end)
    end,
})

--- TYPES
---
---@alias ide.events "IdeLater"
---
---@alias ide.SpecData.Opts table | fun(spec: vim.pack.Spec, opts: table): table?
---
---@class (exact) ide.SpecData
---@field enabled? boolean (default true) when false spec is not included
---@field cond? boolean|fun(plugin_data: vim.pack.PluginData): boolean condition to determine whether plugin should be loaded, evaluated at load time; if false, plugin is not loaded and after hook is not run
---@field build? fun(event: settings.PackEvent) function to run after plugin is installed or updated
---@field opts? ide.SpecData.Opts either a table of options to merge into the plugin spec, or a function that returns such a table
---@field opts_extend? table<string> list of dot separated key paths that should be list-appended instead of overridden when merging opts tables, e.g. {"dependencies", "opts.mason.registries"}
---@field before? fun(plugin_data: vim.pack.PluginData)
---@field after? fun(plugin_data: vim.pack.PluginData, opts: table)
---@field event? vim.api.keyset.events|vim.api.keyset.events[]|ide.events|ide.events[]
---
---@class ide.SpecData.Named : ide.SpecData
---@field [1] string plugin name
---
---@class ide.SpecData.OptsChained : ide.SpecData
---@field opts_chain table<ide.SpecData.Opts> list of opts tables or functions to merge, in order of application (later entries override earlier ones)
---
---@class vim.pack.Spec
---@diagnostic disable-next-line: duplicate-doc-field
---@field data? ide.SpecData
---
---@class settings.PackEvent
---@field active boolean
---@field spec vim.pack.Spec
---@field kind 'install' | 'update' | 'remove'
---
---@alias vim.pack.OnLoad fun(plug_data: vim.pack.PluginData)
---
---@alias vim.pack.PluginData {spec: vim.pack.Spec, path: string}
---
---@class ide.Spec.Builder.Entry
---@field spec? vim.pack.Spec
---@field data_fragments ide.SpecData[]

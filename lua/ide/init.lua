local utils = require("ide.utils")

-- If opened a dir then set it as the cwd and if opened a file then set the
-- file's parent dir as the cwd to narrow down the scope for fzf
-- Later ahmedkhalf/project.nvim will adjust cwd based on .git or LSP
local curr_path = vim.fn.resolve(vim.fn.expand("%"))
if vim.fn.isdirectory(vim.fn.expand("%")) == 1 then
    vim.api.nvim_set_current_dir(curr_path)
elseif vim.fn.filereadable(vim.fn.expand("%")) == 1 then
    vim.api.nvim_set_current_dir(vim.fn.fnamemodify(curr_path, ":p:h"))
end

--- Define custom autocmds
utils.autocmd.create("UIEnter", {
    once = true,
    callback = function()
        vim.api.nvim_exec_autocmds("User", { pattern = "IdeLater", modeline = false })
    end,
})

--- Configure loader for local development versions of plugins.
require("ide.dev").setup()

--- TYPES
---
---@alias ide.events "IdeLater"
---
---@class ide.Dev.Config
---@field path string base dir (string) or per-plugin function returning the full local path
---@field patterns string[]  plain substrings matched against spec.src to auto-enable dev mode
---@field fallback boolean   when true, fall back to remote src if the local directory does not exist
---
---@alias ide.SpecData.Opts table | fun(spec: vim.pack.Spec, opts: table): table?
---
---@class ide.SpecData.Key : vim.keymap.set.Opts
---@field [1] string lhs key sequence
---@field [2]? string|fun() rhs action; when omitted the after hook is expected to register the real mapping
---@field mode? string|string[] mode(s), defaults to "n"
---
---@class (exact) ide.SpecData
---@field enabled? boolean (default true) when false spec is not included
---@field dev? boolean when true, load from local dev path instead of spec.src (see ide.Dev.Config)
---@field cond? boolean|fun(plugin_data: vim.pack.PluginData): boolean condition to determine whether plugin should be loaded, evaluated at load time; if false, plugin is not loaded and after hook is not run
---@field build? fun(event: settings.PackEvent) function to run after plugin is installed or updated
---@field opts? ide.SpecData.Opts either a table of options to merge into the plugin spec, or a function that returns such a table
---@field opts_extend? table<string> list of dot separated key paths that should be list-appended instead of overridden when merging opts tables, e.g. {"dependencies", "opts.mason.registries"}
---@field before? fun(plugin_data: vim.pack.PluginData)
---@field after? fun(plugin_data: vim.pack.PluginData, opts: table)
---@field event? vim.api.keyset.events|vim.api.keyset.events[]|ide.events|ide.events[]
---@field keys? ide.SpecData.Key[] keymaps; when deferred, each lhs becomes a loader stub that loads the plugin on first press then re-fires the key; when deferred=false, registered as normal mappings after load
---@field deferred? boolean (default true) set to false to disable all lazy loading – plugin loads immediately even if event/keys are present; keys are still registered as real mappings after load
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
---
---@class ide.Opts.Treesitter
---@field ensure_installed string[] list of parsers to ensure are installed
---@field syntax_map table<string, string> optional mapping of filetypes to treesitter parser names
---@field auto_install boolean whether to automatically install missing parsers when opening a file
---@field sync_install boolean whether to install parsers synchronously (i.e. blocking)
---@field highlight {enable: boolean} whether to enable treesitter-based syntax highlighting
---@field indent {enable: boolean} whether to enable treesitter-based indentation
---
---@alias ide.LocalSettings table<string, table<string, {
---  use_for: table<kdtsk.tools.Purpose, boolean>, -- use the tool for the given purpose
---  lsp_settings?: table, -- provide settings for LSP
--- }>>
---

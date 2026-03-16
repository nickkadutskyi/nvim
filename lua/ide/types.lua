---@alias ide.events "IdeDeferred"|"IdeDone"|"PackBefore"|"PackLoad"

---@class ide.Dev.Config
---@field path string base dir (string) or per-plugin function returning the full local path
---@field patterns string[]  plain substrings matched against spec.src to auto-enable dev mode
---@field fallback boolean   when true, fall back to remote src if the local directory does not exist

---@alias ide.SpecData.Opts table | fun(spec: vim.pack.Spec, opts: table): table?

---@class ide.SpecData.Key : vim.keymap.set.Opts
---@field lhs string|string[] lhs key sequence
---@field rhs? string|fun() rhs action; when omitted the after hook is expected to register the real mapping
---@field mode? string|string[] mode(s), defaults to "n"
---
---@class (exact) ide.SpecData
---@field enabled? boolean (default true) when false spec is not included
---@field dev? boolean when true, load from local dev path instead of spec.src (see ide.Dev.Config)
---@field dev_name? string optional name to use for dev path (defaults to plugin name);
---@field cond? boolean|fun(plugin_data: vim.pack.PluginData): boolean condition to determine whether plugin should be loaded, evaluated at load time; if false, plugin is not loaded and after hook is not run
---@field build? fun(event: settings.PackEvent) function to run after plugin is installed or updated
---@field opts? ide.SpecData.Opts either a table of options to merge into the plugin spec, or a function that returns such a table
---@field opts_extend? table<string> list of dot separated key paths that should be list-appended instead of overridden when merging opts tables, e.g. {"dependencies", "opts.mason.registries"}
---@field before? fun(plugin_data: vim.pack.PluginData)
---@field after? fun(plugin_data: vim.pack.PluginData, opts: table)
---@field event? vim.api.keyset.events|vim.api.keyset.events[]|ide.events|ide.events[]
---@field ft? string|string[] filetype(s) to load the plugin on (FileType autocmd)
---@field keys? ide.SpecData.Key[] keymaps; when deferred, each lhs becomes a loader stub that loads the plugin on first press then re-fires the key; when deferred=false, registered as normal mappings after load
---@field deferred? boolean (default true) set to false to disable all lazy loading – plugin loads immediately even if event/keys are present; keys are still registered as real mappings after load
---@field [string]? nil

---@class ide.SpecData.Named : ide.SpecData
---@field [1] string plugin name

---@class ide.SpecData.OptsChained : ide.SpecData
---@field opts_chain table<ide.SpecData.Opts> list of opts tables or functions to merge, in order of application (later entries override earlier ones)

---@class (exact) vim.pack.Spec
---@diagnostic disable-next-line: duplicate-doc-field
---@field data? ide.SpecData|ide.SpecData.OptsChained
---@field [string]? nil

---@class settings.PackEvent
---@field active boolean
---@field spec vim.pack.Spec
---@field kind 'install' | 'update' | 'remove'

---@alias vim.pack.OnLoad fun(plug_data: vim.pack.PluginData)

---@alias vim.pack.PluginData {spec: vim.pack.Spec, path: string}

---@class ide.Spec.Builder.Entry
---@field spec? vim.pack.Spec
---@field data_fragments ide.SpecData[]

---@class ide.ParserInfo : ParserInfo
---@field filetypes? string[] list of filetypes to associate with this parser

---@class ide.Opts.Treesitter
---@field ensure_installed? string[] list of parsers to ensure are installed
---@field syntax_map? table<string, string> optional mapping of filetypes to treesitter parser names
---@field auto_install? boolean whether to automatically install missing parsers when opening a file
---@field sync_install? boolean whether to install parsers synchronously (i.e. blocking)
---@field highlight? {enable: boolean} whether to enable treesitter-based syntax highlighting
---@field indent? {enable: boolean} whether to enable treesitter-based indentation
---@field custom_parsers? table<string, ide.ParserInfo>

---@class ide.Opts.Lint
---@field linters? table<string, ide.Linter|fun():ide.Linter>
---@field linters_by_ft? table<string,table<ide.Tool>>

---@class ide.Opts.Conform
---@field formatters_by_ft? table<string, table<ide.Tool>>
---@field conform_opts? conform.setupOpts

---@class ide.Opts.Lsp
---@field clients? table<string, ide.Lsp.Client>

---@class ide.Lsp.Client : vim.lsp.Config
---@field nix_pkg? string
---@field enabled? ide.ToolTest|boolean
---@field bin? string|fun(): string|nil

---@alias ide.LocalSettings table<string, table<string, {
---  use_for: table<kdtsk.tools.Purpose, boolean>, -- use the tool for the given purpose
---  lsp_settings?: table, -- provide settings for LSP
--- }>>

---@class settings.Opts
---@field imports string[] List of modules to import

---@class ide.Linter: lint.Linter
---@field name? string
---@field cmd? string|fun():string
---@field parser? lint.Parser|lint.parse
---@field nix_pkg? string

---@class ide.ToolTest
---@field [1]? string[] Patterns of files. Turns on a tool when file is present
---@field [2]? fun(): boolean Optionally run the function to turn on/off the tool
---@field [3]? boolean Force enable or disable

---@class ide.Tool
---@field [1] string Name of the tool, e.g. phpactor
---@field [2]? string[] Patterns of files. Turns on a tool when file is present
---@field [3]? fun(): boolean Optionally run the function to turn on/off the tool
---@field [4]? boolean Force enable or disable
---@field [5]? table Arbitrary opts to merge into containing table (needed for conform.nvim)

---@alias ide.Scope
---| '"php"'
---| '"lua"'
---| '"typescript"'
---| '"javascript"'
---| '"python"'
---| '"go"'
---| '"zig"'
---| '"yaml"'
---| '"ruby"'
---| '"vue"'
---| '"tailwindcss"'
---| '"blade"'
---| '"twig"'
---| '"css"'
---| '"scss"'
---| '"laravel"'
---| '"symfony"'

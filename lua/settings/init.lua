local import = require("ide.import").import
local spec_builder = require("ide.spec.builder")
local pack = require("ide.pack")

--- OPTIONS --------------------------------------------------------------------

--- Project-specific setting provides by .nvim.lua
---@type ide.LocalSettings
vim.g.settings = nil
---@type boolean
vim.g.settings_loaded = false

--- MODULE DEFINITION ----------------------------------------------------------

local M = {}
local I = {}

---@class settings.Opts
---@field imports string[] List of modules to import
---
---@param opts settings.Opts
function M.setup(opts)
    opts = opts or {}
    opts.imports = opts.imports or {}

    for _, module in ipairs(opts.imports) do
        import(module)
    end

    --- Load plugins after all specs have been added and merged
    pack.load(spec_builder.get_specs())
end

return M

local import = require("ide.import").import
local spec = require("ide.spec.builder")
local pack = require("ide.pack")

--- MODULE DEFINITION ----------------------------------------------------------

local M = {}
local I = {}

---@param opts settings.Opts
function M.setup(opts)
    opts = opts or {}
    opts.imports = opts.imports or {}

    --- Project-specific setting provides by .nvim.lua
    ---@type ide.LocalSettings
    vim.g.settings = nil
    ---@type boolean
    vim.g.settings_loaded = false

    for _, module in ipairs(opts.imports) do
        import(module)
    end

    --- Load plugins after all specs have been added and merged
    pack.load(spec.get_specs())
end

return M

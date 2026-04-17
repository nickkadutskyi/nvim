local pack = require("ide.pack")

--- MODULE DEFINITION ----------------------------------------------------------
local M = {}
local I = {
    symbols = {
        no_icons = { [1] = "E:", [2] = "W:", [3] = "We:", [4] = "C:" },
    },
}

---@param props table
function M.component_diagnostics(props)
    local label = {}

    local icons = I.symbols.no_icons
    if pack.is_loaded("jb.nvim") and vim.g.nerd_font_is_present then
        icons = require("jb.icons").diagnostic or "rounded"
    end
    for severity = 1, 4 do
        local n = #vim.diagnostic.get(props.buf, { severity = vim.diagnostic.severity[severity] })
        local name = vim.diagnostic.severity[severity]
        if n > 0 then
            table.insert(label, { icons[severity] .. " ", group = "DiagnosticSign" .. name })
            table.insert(label, { n .. " " })
        end
    end
    return label
end

return M

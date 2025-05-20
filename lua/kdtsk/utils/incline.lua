---@class kdtsk.utils.incline
local M = {}

-- default symbols for diagnostics component
M.symbols = {
    icons = require("jb.icons").diagnostic,
    no_icons = { [1] = "E:", [2] = "W:", [3] = "We:", [4] = "C:" },
}

---@param props table
function M.component_diagnostics(props)
    local label = {}

    local icons = vim.g.nerd_font_is_present and M.symbols.icons or M.symbols.no_icons
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

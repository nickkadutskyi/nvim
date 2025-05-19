---@class kdtsk.utils.incline
local M = {}

-- default symbols for diagnostics component
M.symbols = {
    icons = {
        error = "󰀨 ",
        warn = " ",
        info = " ", -- Weak Warning
        hint = "󰋼 ", -- Consideration
    },
    no_icons = { error = "E:", warn = "W:", info = "We:", hint = "C:" },
}

---@param props table
function M.component_diagnostics(props)
    local label = {}

    local icons = vim.g.nerd_font_is_present and M.symbols.icons or M.symbols.no_icons
    for severity, icon in pairs(icons) do
        local n = #vim.diagnostic.get(props.buf, {
            severity = vim.diagnostic.severity[string.upper(severity)],
        })
        if n > 0 then
            table.insert(label, { icon, group = "DiagnosticSign" .. severity })
            table.insert(label, { n .. " " })
        end
    end
    return label
end

return M

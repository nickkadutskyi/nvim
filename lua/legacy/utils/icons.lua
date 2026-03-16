---@class kdtsk.utils.icons
local M = {}

---@type table<vim.diagnostic.Severity, string>
M.diagnostic = {}

---@type table<string, string>
M.kind = {}

---@type table<string, table<string, string>>
M.files = {
    by_filename = {},
    by_extension = {},
    by_filetype = {},
}

return M

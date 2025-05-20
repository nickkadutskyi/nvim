-- Show module name (project directory or current cwd basename)
-- if no file is open or if current file is in cwd

-- if current file is outside of cwd, try to get its' module name

local M = require("lualine.component"):extend()
local utils = require("lualine.utils.utils")
local highlight = require("lualine.highlight")

local default_options = {
    icon = { "󱓼" },
    -- icon_color_highlight = "JBIconModule",
}

function M:init(options)
    M.super.init(self, options)
    self.options = vim.tbl_deep_extend("keep", self.options or {}, default_options)
end

function M:update_status()
    -- self.status = "module"
    return "module"
end

return M

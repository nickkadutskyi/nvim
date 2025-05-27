-- 󱓼 [cwd name|root name if file is outside of cwd] [path] [filetype] [filename]
-- Show module name (project directory or current cwd basename)
-- if no file is open or if current file is in cwd

-- if current file is outside of cwd, try to get its' module name

local M = require("lualine.component"):extend()
local utils = require("lualine.utils.utils")
local highlight = require("lualine.highlight")

local default_options = {
    padding = { left = 1, right = 0 }, -- padding around the icon
    -- icon_color_highlight = "JBIconModule",
    -- icon_color_current_highlight = "JBIconModuleProject",

    ---@class NavBarOptions
    nav_bar_opts = {
        separator = " › ", -- separator between nav bar items
        icon = { "󱓼 ", hl = "JBIconModuleProject" }, -- icon for the nav bar},
        hl = "",
    },
}

-- State

local _cache = {
    cwd = nil,
    in_cwd = {},
    project_name = nil,
}

local _nav_state = {
    components = {},
    current_index = nil,
}

-- Helpers

---@return string
local function get_cwd()
    if not _cache.cwd then
        _cache.cwd = vim.fn.getcwd()
    end
    return _cache.cwd
end

---@return string
local function get_project_name()
    if not _cache.project_name then
        _cache.project_name = vim.fn.fnamemodify(get_cwd(), ":t")
    end
    return _cache.project_name
end

---@param path string
---@return boolean
local function is_in_cwd(path)
    assert(type(path) == "string" and path ~= "", "Path must be a non-empty string")

    if _cache.in_cwd[path] ~= nil then
        return _cache.in_cwd[path]
    else
        _cache.in_cwd[path] = path:find(get_cwd(), 1, true) == 1
    end

    return _cache.in_cwd[path]
end

---@param path string
---@return string
local function get_module_name(path)
    if is_in_cwd(path) then
        return get_project_name()
    else
        -- TODO: Implement logic to get module name for files outside of cwd
        return "-"
    end
end

---@class NavBarOptions
local function build_nav_components(config)
    local path = vim.fn.expand("%:p")
    if path == "" then
        return _nav_state.components or {}
    end
    local components = {}

    -- Adds module
    local module_icon = config.icon
    -- Do not use ProjectColor for Icon if the file is not in cwd
    if not is_in_cwd(path) then
        module_icon = vim.tbl_deep_extend("force", config.icon, { hl = "JBIconModule" })
    end
    table.insert(components, {
        icon = module_icon,
        text = get_module_name(path),
    })


    -- TODO: Add path component
    -- TODO: Add filename component with filetype icon
    -- TODO: Add navic component if available

    -- Store components in the navigation state
    _nav_state.components = components
    _nav_state.current_index = #components

    return components
end

-- Lualine API

function M:init(options)
    M.super.init(self, options)
    self.options = vim.tbl_deep_extend("keep", self.options or {}, default_options)
end

function M:update_status()
    ---@type NavBarOptions
    local config = self.options.nav_bar_opts
    local components = build_nav_components(config)

    local result_parts = {}
    for i, component in ipairs(components) do
        -- Process icon
        local icon = component.icon[1]
        local icon_hl = component.icon.hl or config.icon.hl or nil
        if icon and icon_hl then
            icon = "%#" .. icon_hl .. "#" .. icon .. "%*"
        end

        -- Process text
        local text = component.text
        local text_hl = component.hl or config.hl or nil
        if text_hl then
            text = "%#" .. text_hl .. "#" .. text .. "%*"
        end
        local part = icon .. text

        table.insert(result_parts, part)
    end

    local result = table.concat(result_parts, config.separator)

    -- return is_in_cwd(path) and (get_project_name() .. self.options.nav_bar_opts.separator) or ""
    return result .. (config.separator or "")
end

-- Autocmds

vim.api.nvim_create_autocmd({ "DirChanged" }, {
    group = vim.api.nvim_create_augroup("nav_bar-dir-changed", { clear = true }),
    callback = function(event)
        -- clears cached cwd when directory changes
        _cache.cwd = nil
        _cache.in_cwd = {}
    end,
})

return M

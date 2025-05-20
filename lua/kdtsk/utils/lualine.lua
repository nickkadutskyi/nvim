---@class kdtsk.utils.lualine
local M = {}

---Macro recording status
---@return string
function M.component_macro_recording()
    return _G._editor_macro_recording and " " .. _G._editor_macro_recording or ""
end

---Gets the project abbreviation based on the current working directory
function M.project_abbreviation()
    -- Cache the project abbreviation
    if not _G._project_abbrev_cache then
        _G._project_abbrev_cache = {}
    end

    local cwd = vim.fn.getcwd()
    if _G._project_abbrev_cache[cwd] then
        return _G._project_abbrev_cache[cwd]
    end

    local projectName = vim.fs.basename(cwd)
    if projectName == "" then
        return "ø" -- Handle empty project name
    end

    -- Generate abbreviation
    local result
    local parts = {}
    for part in string.gmatch(projectName, "([^-_,%s.]+)") do
        table.insert(parts, part)
    end

    if #parts == 0 then
        -- Only special characters in project name
        result = string.upper(string.sub(projectName, 1, 1))
    elseif #parts == 1 then
        -- Single word project name, use first two characters
        local word = parts[1]
        if #word == 1 then
            result = string.upper(word)
        else
            result = string.upper(string.sub(word, 1, 1)) .. string.upper(string.sub(word, 2, 2))
        end
    else
        -- Multi-word project name
        -- Get first letter of first and last words
        result = string.upper(string.sub(parts[1], 1, 1)) .. string.upper(string.sub(parts[#parts], 1, 1))
    end

    -- Cache and return
    _G._project_abbrev_cache[cwd] = result
    return result
end

--- Show delta icon if there are uncommitted changes
--- or empty icon if there are no changes
--- or hide if there are unsaved buffers
function M.gitstat_subsec_delta(status)
    if _G._buffer_modified_count and _G._buffer_modified_count > 0 then
        return nil
    end
    if status.is_dirty or status.staged > 0 then
        return vim.g.nerd_font_is_present and "󰇂" or "Δ"
    else
        return "∅"
    end
end

--- Show delta icon if there are uncommitted changes
function M.gitstat_subsec_is_dirty(status)
    if _G._buffer_modified_count and _G._buffer_modified_count > 0 then
        return nil
    end
    if status.is_dirty or status.staged > 0 then
        return vim.g.nerd_font_is_present and " 󰇂" or " Δ"
    end
end

--- Show empty icon if there are no changes
function M.gitstat_subsec_is_clean(status)
    if _G._buffer_modified_count and _G._buffer_modified_count > 0 then
        return nil
    end
    if not (status.is_dirty or status.staged > 0) then
        return " ∅"
    end
end

--- Show icon if there are unsaved buffers
function M.gitstat_subsec_has_unsaved_buffers()
    local current_time = vim.loop.now()
    if current_time - _G._buffer_modified_last_check_time > 500 then
        local count, _ = Utils.count_modified_buffers()
        _G._buffer_modified_count = count
    end
    _G._buffer_modified_last_check_time = current_time

    if _G._buffer_modified_count > 0 then
        return " 󰽃"
    end
end

return M

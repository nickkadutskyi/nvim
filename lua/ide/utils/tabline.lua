--- MODULE DEFINITION ----------------------------------------------------------

---@class ide.Utils.Tabline
local M = {}
local I = {}

---Collect raw display info for a single tab without deduplication applied.
---Returns a table with the base name, the underlying bufname (for parent
---resolution), a flag indicating whether it is a regular file path, and the
---modified state.
---@param tabnr number Tab page number
---@return { name: string, bufname: string, is_file: boolean, modified: boolean }
function I.get_tab_info(tabnr)
    local winnr = vim.fn.tabpagewinnr(tabnr)
    local buflist = vim.fn.tabpagebuflist(tabnr)
    local bufnr = buflist[winnr]
    local bufname = vim.fn.bufname(bufnr)
    local modified = vim.fn.getbufvar(bufnr, "&mod") == 1

    local name
    local is_file = false

    if bufname == "" then
        name = "[No Name]"
    elseif bufname:match("term://") then
        local path_parts = vim.fn.split(bufname, ":")
        name = "term " .. path_parts[#path_parts]
    elseif bufname:match("diffview://") then
        name = "diff " .. bufname:gsub(vim.fn.getcwd(), ""):gsub("diffview:///", "")
    elseif bufname:match("^.+://") then
        name = bufname
    else
        name = vim.fn.fnamemodify(bufname, ":t")
        is_file = true
    end

    return { name = name, bufname = bufname, is_file = is_file, modified = modified }
end

---Resolve duplicate display names across all tabs by prepending the immediate
---parent directory for any regular-file tab whose base filename appears more
---than once.  Special buffers ([No Name], term, diffview, etc.) are left as-is
---even if they share a label, since there is no meaningful path to pull from.
---@param tabs { name: string, bufname: string, is_file: boolean, modified: boolean }[]
function I.resolve_duplicates(tabs)
    -- Count how many tabs share each base name
    local counts = {}
    for _, tab in ipairs(tabs) do
        counts[tab.name] = (counts[tab.name] or 0) + 1
    end

    -- For file-based tabs whose name is not unique, prepend the parent dir
    for _, tab in ipairs(tabs) do
        if tab.is_file and counts[tab.name] > 1 then
            local parent = vim.fn.fnamemodify(tab.bufname, ":h:t")
            if parent ~= "" and parent ~= "." then
                tab.name = parent .. "/" .. tab.name
            end
        end
    end
end

---Generate the tabline string with a clickable x close button on each tab.
---Uses %NT for tab-select clicks and %NX...%X for per-tab close clicks.
---Tabs sharing the same filename get their immediate parent directory prepended
---so every label stays unique.
---@return string
function M.tabline()
    local total = vim.fn.tabpagenr("$")
    local current = vim.fn.tabpagenr()

    -- First pass: collect raw info for all tabs
    local tabs = {}
    for i = 1, total do
        tabs[i] = I.get_tab_info(i)
    end

    -- Second pass: disambiguate duplicate filenames
    I.resolve_duplicates(tabs)

    -- Build the tabline string
    local close_icon = "" --- x X     󰅙
    local tabline = ""
    for i, tab in ipairs(tabs) do
        local is_sel = i == current

        -- Left border (selected only) then tab highlight
        if is_sel then
            tabline = tabline .. "%#TabLineBorderSel#▏"
            tabline = tabline .. "%#TabLineSel#"
        else
            tabline = tabline .. "%#TabLine#"
        end

        -- Tab select-click target
        tabline = tabline .. "%" .. i .. "T"

        -- Display name with optional modified indicator
        local label = tab.name
        if tab.modified then
            label = label .. " [+]"
        end
        if is_sel then
            tabline = tabline .. "" .. label .. " "
        else
            tabline = tabline .. " " .. label .. " "
        end

        -- Close button with its own highlight
        local close_hl = is_sel and "%#TabLineCloseIconSel#" or "%#TabLineCloseIcon#"
        tabline = tabline .. close_hl .. "%" .. i .. "X" .. close_icon .. "%X"

        -- Right border (selected only) then gap
        if is_sel then
            tabline = tabline .. "%#TabLineBorderSel#▕"
            tabline = tabline .. "%#TabLine#"
        else
            tabline = tabline .. "%#TabLine# "
        end
    end

    -- Fill remainder and reset click targets
    tabline = tabline .. "%#TabLineFill#%T"

    return tabline
end

return M

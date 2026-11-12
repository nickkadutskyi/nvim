-- Shows the nearest jj bookmark, like the "branch" component does for git, followed by
-- CHANGED_ICON when the current change has file changes.
-- Uses starship's jj_bookmark and jj_status modules when starship is installed, otherwise jj directly.
local M = require("lualine.component"):extend()

local CACHE_DURATION = 2000 -- 2 seconds in milliseconds
local DEBOUNCE_DELAY = 200 -- 200ms debounce
local UNFOCUS_THRESHOLD = 60000 -- 1 minute in milliseconds
local SEARCH_DEPTH = 15 -- how many ancestors of @ to search for a bookmark (jj only)
local CHANGED_ICON = "󰇂" -- must match the icon in starship's jj_status format

local cache = {
    result = nil, -- { bookmark = string, changed = boolean } once fetched
    timestamp = 0,
    debounce_timer = nil,
    running = false,
    request_id = 0,
    is_jj_repo = nil, -- nil = unknown, true = jj repo, false = not jj repo
    focus_lost_time = nil, -- when focus was lost
}

local function strip_ansi(text)
    return (text:gsub("\27%[[0-9;]*m", ""))
end

local command, parse
if vim.fn.executable("starship") == 1 then
    command = { "sh", "-c", "starship module jj_bookmark; echo; starship module jj_status" }
    parse = function(stdout)
        local bookmark, status = strip_ansi(stdout):match("^([^\n]*)\n?(.*)$")
        return { bookmark = vim.trim(bookmark), changed = status:find(CHANGED_ICON, 1, true) ~= nil }
    end
else
    command = {
        "jj",
        "--ignore-working-copy",
        "--no-pager",
        "--color=never",
        "log",
        "--no-graph",
        "-r",
        ("@ | latest(bookmarks() & ancestors(@, %d), 1)"):format(SEARCH_DEPTH),
        "-T",
        'if(current_working_copy, if(empty, "clean", "changed")) ++ "\t" ++ local_bookmarks.map(|b| b.name()).join(" ") ++ "\n"',
    }
    -- One line per revision, @ first: "<clean|changed or empty for non-@>\t<bookmarks>"
    parse = function(stdout)
        local result = { bookmark = "", changed = false }
        for state, bookmarks in stdout:gmatch("(%a*)\t([^\n]*)") do
            result.changed = result.changed or state == "changed"
            if result.bookmark == "" then
                result.bookmark = bookmarks
            end
        end
        return result
    end
end

local function should_use_extended_cache()
    return cache.focus_lost_time ~= nil and (vim.uv.now() - cache.focus_lost_time) > UNFOCUS_THRESHOLD
end

local function is_jj_repo()
    if cache.is_jj_repo == nil then
        cache.is_jj_repo = vim.fs.root(vim.fn.getcwd(), ".jj") ~= nil
    end
    return cache.is_jj_repo
end

local function get_status()
    if not is_jj_repo() then
        return nil
    end

    -- If unfocused for more than 1 minute, always return cached result
    if should_use_extended_cache() and cache.result then
        return cache.result
    end

    -- Return cached result if still valid, or while a refresh is pending
    local fresh = cache.result and (vim.uv.now() - cache.timestamp) < CACHE_DURATION
    if fresh or cache.debounce_timer or cache.running then
        return cache.result
    end

    cache.debounce_timer = vim.defer_fn(function()
        cache.debounce_timer = nil
        cache.running = true
        cache.request_id = cache.request_id + 1
        local request_id = cache.request_id

        local function finish(result)
            if request_id ~= cache.request_id then
                return
            end
            cache.running = false
            cache.result = result
            cache.timestamp = vim.uv.now()
            vim.schedule(function()
                vim.cmd.redrawstatus()
            end)
        end

        -- An empty STARSHIP_SHELL stops starship from wrapping colors in shell prompt escapes
        local ok = pcall(vim.system, command, { text = true, env = { STARSHIP_SHELL = "" } }, function(result)
            finish(result.code == 0 and parse(result.stdout or "") or nil)
        end)
        if not ok then
            finish(nil)
        end
    end, DEBOUNCE_DELAY)

    return cache.result
end

function M:update_status()
    local status = get_status()
    if not status then
        return ""
    end

    local parts = {}
    if status.bookmark ~= "" then
        table.insert(parts, status.bookmark)
    end
    if status.changed then
        table.insert(parts, CHANGED_ICON)
    end
    return table.concat(parts, " ")
end

-- Used by the "branch" component to hide itself inside jj repos
function M.is_jujutsu_repo()
    return is_jj_repo()
end

-- Reset cache when directory changes
vim.api.nvim_create_autocmd("DirChanged", {
    group = vim.api.nvim_create_augroup("jujutsu-dir-changed", { clear = true }),
    callback = function()
        if cache.debounce_timer then
            cache.debounce_timer:close()
        end
        cache = {
            result = nil,
            timestamp = 0,
            debounce_timer = nil,
            running = false,
            request_id = cache.request_id + 1,
            is_jj_repo = nil,
            focus_lost_time = nil,
        }
    end,
})

-- Track focus state for extended caching
local focus_group = vim.api.nvim_create_augroup("jujutsu-focus", { clear = true })
vim.api.nvim_create_autocmd("FocusLost", {
    group = focus_group,
    callback = function()
        cache.focus_lost_time = vim.uv.now()
    end,
})
vim.api.nvim_create_autocmd("FocusGained", {
    group = focus_group,
    callback = function()
        cache.focus_lost_time = nil
    end,
})

return M

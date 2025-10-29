local M = require("lualine.component"):extend()

local cache = {
    result = nil,
    timestamp = 0,
    debounce_timer = nil,
    is_jj_repo = nil, -- nil = unknown, true = jj repo, false = not jj repo
    focus_lost_time = nil, -- when focus was lost
}

local CACHE_DURATION = 400 -- 1 second in milliseconds
local DEBOUNCE_DELAY = 200 -- 400ms debounce
local UNFOCUS_THRESHOLD = 60000 -- 1 minute in milliseconds

local default_options = {}

local function should_use_extended_cache()
    if not cache.focus_lost_time then
        return false
    end

    local current_time = vim.loop.now()
    return (current_time - cache.focus_lost_time) > UNFOCUS_THRESHOLD
end

local function get_jujutsu_status()
    local current_time = vim.loop.now()

    -- If unfocused for more than 1 minute, always return cached result
    if should_use_extended_cache() and cache.result then
        return cache.result
    end

    -- Return cached result if still valid
    if cache.result and (current_time - cache.timestamp) < CACHE_DURATION then
        return cache.result
    end

    -- Use cached result while waiting for debounce
    if cache.debounce_timer then
        return cache.result or ""
    end

    -- Set up debounced execution
    cache.debounce_timer = vim.defer_fn(function()
        cache.debounce_timer = nil

        -- Get jujutsu status via starship-jj and clear ANSI codes
        local handle = io.popen('starship-jj --ignore-working-copy starship prompt 2>/dev/null | sed \'s/\\x1b\\[[0-9;]*m//g\' | xargs ; echo "EXIT_CODE:$?"')
        if not handle then
            cache.result = ""
            cache.timestamp = current_time
            return
        end

        local output = handle:read("*all")
        handle:close()

        -- Extract exit code from the output
        local command_output, exit_code_str = output:match("^(.*)EXIT_CODE:(%d+)%s*$")
        local exit_code = tonumber(exit_code_str) or 1

        if exit_code == 0 and command_output and vim.trim(command_output) ~= "" then
            -- Remove ANSI escape codes and trailing whitespace/newlines
            -- We are not cleaning ANSI codes here because we already did it in the shell command
            -- local cleaned = command_output:gsub("\27%[[0-9;]*m", "")
            local cleaned = command_output
            cache.result = vim.trim(cleaned)
            cache.is_jj_repo = true
        else
            cache.result = ""
            cache.is_jj_repo = false
        end

        cache.timestamp = vim.loop.now()
    end, DEBOUNCE_DELAY)

    -- Return cached result or empty string while waiting
    return cache.result or ""
end

function M:init(options)
    M.super.init(self, options)
    self.options = vim.tbl_deep_extend("keep", self.options or {}, default_options)
end

function M:update_status()
    local status = get_jujutsu_status()

    -- Only return status if it's not empty (hide component when not in jujutsu repo)
    if status == "" then
        return ""
    end

    return status
end

-- Helper function to check if current directory is a jujutsu repo
-- Once detected, remembers the repo type permanently until directory change
function M.is_jujutsu_repo()
    -- If we already know the repo type, return it immediately
    if cache.is_jj_repo ~= nil then
        return cache.is_jj_repo
    end

    -- First time - trigger detection but don't wait for it
    get_jujutsu_status()

    -- Return false until we know for sure (avoids showing branch initially)
    return false
end

-- Reset cache when directory changes
vim.api.nvim_create_autocmd({ "DirChanged" }, {
    group = vim.api.nvim_create_augroup("jujutsu-dir-changed", { clear = true }),
    callback = function()
        cache.result = nil
        cache.timestamp = 0
        cache.is_jj_repo = nil
        cache.focus_lost_time = nil
        if cache.debounce_timer then
            cache.debounce_timer:close()
            cache.debounce_timer = nil
        end
    end,
})

-- Track focus state for extended caching
vim.api.nvim_create_autocmd({ "FocusLost" }, {
    group = vim.api.nvim_create_augroup("jujutsu-focus", { clear = true }),
    callback = function()
        cache.focus_lost_time = vim.loop.now()
    end,
})

vim.api.nvim_create_autocmd({ "FocusGained" }, {
    group = vim.api.nvim_create_augroup("jujutsu-focus", { clear = false }),
    callback = function()
        cache.focus_lost_time = nil
    end,
})

return M

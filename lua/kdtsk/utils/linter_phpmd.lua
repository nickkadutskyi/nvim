---@class kdtsk.utils.linter_phpmd
local M = {}

-----------------------------------------------------------------------------
-- Strip non-fatal PHP diagnostics (Deprecated/Warning/Notice) from mixed
-- stdout/stderr and return the pure JSON part.
--
-- Usage:
--   local ok, json_or_err = strip_deprecations(output_from_php_tool)
--   if ok then
--     -- json_or_err is the JSON string you're after
--   else
--     -- json_or_err contains the original output so you can surface the error
--   end
-----------------------------------------------------------------------------

-- patterns considered "harmless" (safe to drop)
local IGNORE_PATTERNS = {
    "^Deprecated:",
    "^PHP%s+Deprecated:",
    "^Warning:",
    "^PHP%s+Warning:",
    "^Notice:",
    "^PHP%s+Notice:",
}

-- patterns that really mean the tool blew up (do NOT hide)
local FATAL_PATTERNS = {
    "^Fatal%s+error:",
    "^PHP%s+Fatal%s+error:",
    "^Parse%s+error:",
}

local function is_match(line, patterns)
    for _, pat in ipairs(patterns) do
        if line:match(pat) then
            return true
        end
    end
    return false
end

--- Strip deprecation / warning / notice noise and return only JSON.
-- @return ok     (boolean) true  -> 'json' holds pure JSON
--                         false -> 'json' holds original output (fatal)
-- @return json   (string)
---@param output string mixed stdout/stderr from PHP process
---@return boolean, string -- ok, json
function M.strip_deprecations(output)
    -- quick check: if we see a fatal pattern anywhere, give up early
    for line in output:gmatch("[^\r\n]+") do
        if is_match(line, FATAL_PATTERNS) then
            return false, output -- bubble the real error up
        end
    end

    -- otherwise remove ignorable lines
    local cleaned = {}
    for line in output:gmatch("[^\r\n]+") do
        if not is_match(line, IGNORE_PATTERNS) then
            table.insert(cleaned, line)
        end
    end

    local stripped = table.concat(cleaned, "\n")

    -- finally, trim everything *before* the first '{'
    local first_brace = stripped:find("{", 1, true)
    if first_brace then
        stripped = stripped:sub(first_brace)
    end

    return true, stripped
end

return M

local pack = require("ide.pack")

--- MODULE DEFINITION ----------------------------------------------------------
local M = {}
local I = {
    symbols = {
        no_icons = { [1] = "E:", [2] = "W:", [3] = "We:", [4] = "C:" },
    },
    spell_cache = {},
}

-- Accepting words does not change the buffer's edit counter.
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI", "OptionSet", "BufWipeout" }, {
    group = vim.api.nvim_create_augroup("ide.incline.spell", { clear = true }),
    callback = function()
        I.spell_cache = {}
    end,
})

---@param props table
---@return table[]
function I.native_spelling(props)
    if not vim.wo[props.win].spell then
        return {}
    end
    local tick = vim.api.nvim_buf_get_changedtick(props.buf)
    local cached = I.spell_cache[props.buf]
    if cached and cached.tick == tick then
        return cached.words
    end

    local words = vim.api.nvim_win_call(props.win, function()
        local view = vim.fn.winsaveview()
        local ok, result = pcall(function()
            local found = {}
            for lnum, line in ipairs(vim.api.nvim_buf_get_lines(props.buf, 0, -1, false)) do
                vim.api.nvim_win_set_cursor(0, { lnum, 0 })
                while true do
                    -- Checking the buffer respects the editor's spell regions; checking a string does not.
                    local word = vim.fn.spellbadword()
                    if word[1] == "" then
                        break
                    end
                    local col = vim.api.nvim_win_get_cursor(0)[2]
                    table.insert(
                        found,
                        { lnum = lnum - 1, col = col, kind = word[2] == "caps" and "Grammar" or "Typo" }
                    )
                    if col + #word[1] >= #line then
                        break
                    end
                    vim.api.nvim_win_set_cursor(0, { lnum, col + #word[1] })
                end
            end
            return found
        end)
        vim.fn.winrestview(view)
        if not ok then
            error(result)
        end
        return result
    end)
    I.spell_cache[props.buf] = { tick = tick, words = words }
    return words
end

---@param diagnostic vim.Diagnostic
---@return string|nil
function I.language_inspection(diagnostic)
    if diagnostic.source ~= "LTeX" then
        return nil
    end

    -- LTeX uses LanguageTool rule IDs; severity does not distinguish spelling from grammar.
    local code = tostring(diagnostic.code or "")
    if
        code:match("^MORFOLOGIK_")
        or code:match("^HUNSPELL_")
        or code:match("_SPELLER_RULE$")
        or code:match("_SPELLING_RULE$")
        or code:find("ORTHOGRAPHY", 1, true)
        or code:find("_SIMPLE_REPLACE_", 1, true)
        or code == "MUZSKY_ROD_NEZIV_A"
        or code == "ZENSKY_ROD_A"
        or code == "STREDNY_ROD_A"
    then
        return "Typo"
    end
    -- Unknown or missing rule IDs stay in the grammar bucket.
    return "Grammar"
end

---@param props table
function M.component_diagnostics(props)
    local label = {}
    local counts = { 0, 0, 0, 0, Grammar = 0, Typo = 0 }
    local language_diagnostics = {}
    for _, diagnostic in ipairs(vim.diagnostic.get(props.buf)) do
        local language_kind = I.language_inspection(diagnostic)
        local kind = language_kind or diagnostic.severity
        counts[kind] = counts[kind] + 1
        if language_kind then
            table.insert(language_diagnostics, diagnostic)
        end
    end
    for _, word in ipairs(I.native_spelling(props)) do
        local covered = false
        for _, diagnostic in ipairs(language_diagnostics) do
            if
                word.lnum >= diagnostic.lnum
                and word.lnum <= diagnostic.end_lnum
                and (word.lnum ~= diagnostic.lnum or word.col >= diagnostic.col)
                and (word.lnum ~= diagnostic.end_lnum or word.col < diagnostic.end_col)
            then
                covered = true
                break
            end
        end
        if not covered then
            counts[word.kind] = counts[word.kind] + 1
        end
    end

    local icons = I.symbols.no_icons
    if pack.is_loaded("jb.nvim") and vim.g.nerd_font_is_present then
        icons = require("jb.icons").diagnostic or "rounded"
    end
    for severity = 1, 4 do
        local n = counts[severity]
        local name = vim.diagnostic.severity[severity]
        if n > 0 then
            table.insert(label, { icons[severity] .. " ", group = "DiagnosticSign" .. name })
            table.insert(label, { n .. " " })
        end
    end
    for _, kind in ipairs({ "Grammar", "Typo" }) do
        local n = counts[kind]
        if n > 0 then
            table.insert(label, { " ", group = "Custom_Icons_" .. kind })
            table.insert(label, { n .. " " })
        end
    end
    return label
end

return M

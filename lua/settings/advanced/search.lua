local spec = require("ide.spec.builder")

spec.add({
    "dmtrKovalenko/fff.nvim",
    opts = {
        base_path = vim.fn.getcwd(),
        prompt = "   ",
        title = "Files",
        layout = {
            -- height = 25,
            -- width = 95,
            height = function(_terminal_width, terminal_height)
                return 28 / terminal_height
            end,
            width = function(terminal_width, _terminal_height)
                return 98 / terminal_width
            end,
            flex = false,
            prompt_position = "top", -- or 'top'
            preview_position = "bottom", -- or 'left', 'right', 'top', 'bottom'
            preview_size = 0.5,
        },
        preview = {
            -- enabled = false,
            line_numbers = true,
        },
        hl = {
            border = "FloatBorder",
            normal = "FzfLuaFzfNormal",
            cursor = "FzfLuaFzfCursorLine",
            matched = "FzfLuaFzfMatch",
            title = "FzfLuaTitle",
            prompt = "FzfLuaFzfPrompt",
            active_file = "FzfLuaFzfCursorLine",
            frecency = "Number",
            debug = "Comment",

            combo_header = "Number",
            scrollbar = "FzfLuaFzfScrollbar", -- Highlight for scrollbar thumb (track uses border)

            -- Grep highlights
            grep_match = "CustomFFFGrepMatch", -- Highlight for matched text in grep results
            grep_line_number = "CustomFFFGrepLineNr", -- Highlight for :line:col location
            grep_regex_active = "CustomFFFRegexActive", -- Highlight for keybind + label when regex is on
            grep_regex_inactive = "CustomFFFRegexInactive", -- Highlight for keybind + label when regex is off
            grep_fuzzy_active = "CustomFFFRegexInactive", -- Highlight for keybind + label when fuzzy is on
            -- Cross-mode suggestion highlights
            suggestion_header = "WarningMsg", -- Highlight for the "No results found. Suggested..." banner
        },
        keymaps = {
            -- goes to the previous query in history
            cycle_previous_query = "<C-h>",
            select_tab = { "<C-t>", "<M-CR>" },
        },
        -- Git integration
        git = {
            status_text_color = true, -- Apply git status colors to filename text (default: false, only sign column)
        },
        grep = {
            max_file_size = 10 * 1024 * 1024, -- Skip files larger than 10MB
            max_matches_per_file = 200, -- Maximum matches per file
            smart_case = true, -- Case-insensitive unless query has uppercase
            time_budget_ms = 150, -- Max search time in ms per call (prevents UI freeze, 0 = no limit)
            modes = { "plain", "fuzzy", "regex" }, -- Available grep modes and their cycling order
        },
    },
})

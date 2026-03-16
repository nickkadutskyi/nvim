local spec = require("ide.spec.builder")

--- OPTIONS --------------------------------------------------------------------

-- Search text in file
-- Case-insensitive searching UNLESS \C or capital in search
vim.opt.ignorecase = true
vim.opt.smartcase = true
-- Incremental search
vim.opt.incsearch = true

--- PLUGINS --------------------------------------------------------------------

spec.add({
    "fff.nvim",
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
            -- TODO: check if this works
            show_scrollbar = false,
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

spec.add({
    "fzf-lua",
    opts = {
        winopts = {
            height = 25, -- window height
            width = 85,
            row = 0.35,
            zindex = 100,
            preview = {
                title_pos = "left",
                scrollbar = false,
                layout = "vertical",
                vertical = "down:60%",
                winopts = {},
            },
        },
        actions = {
            -- Pickers inheriting these actions:
            --   files, git_files, git_status, grep, lsp, oldfiles, quickfix, loclist,
            --   tags, btags, args, buffers, tabs, lines, blines
            files = { true },
        },
        fzf_colors = true,
        fzf_opts = {
            ["--layout"] = "reverse",
            ["--separator"] = "‾",
        },
        defaults = {
            winopts = {
                title_pos = "left",
                height = 25, -- window height
                width = 95,
                row = 0.35,
                preview = {
                    winopts = {},
                },
            },
            cwd_prompt = false,
            prompt = "   ",
            header = false,
        },
        files = {
            winopts = {
                title = " Files ",
                height = 25, -- window height
                width = 95,
                row = 0.35,
            },
            prompt = "   ",
            -- formatter = { "path.filename_first", 2 },
            -- formatter = "path.filename_first",
            formatter = "path.dirname_first",
            no_ignore = true,
            previewer = "builtin",
        },
        buffers = {
            winopts = {
                title = " Switcher ",
                preview = {
                    hidden = true,
                },
            },
            prompt = "  ",
        },
        grep = {
            winopts = {
                title = " Find in Files ",
                height = 25, -- window height
                width = 85,
                row = 0.35,
            },
            prompt = "   ",
            previewer = "builtin",
            formatter = "path.dirname_first",
            -- formatter = "path.filename_first",
            RIPGREP_CONFIG_PATH = vim.env.RIPGREP_CONFIG_PATH,
            no_ignore = true,
            hidden = true,
        },
        lsp = {
            symbols = {
                symbol_hl = function(s)
                    -- `JBIcon<Kind>` generated in jb.nvim colorscheme
                    return "JBIcon" .. s:lower()
                end,
            },
        },
        previewers = {
            builtin = {
                title_fnamemodify = function(s)
                    -- Get absolute path of parent directory
                    local absParentPath = vim.fn.fnamemodify(s, ":h")
                    -- Convert absolute path to path relative to cwd
                    local relParentPath = vim.fn.fnamemodify(absParentPath, ":~:.")

                    local path = require("fzf-lua.path")
                    local name = path.tail(s)

                    -- Handle case when file is outside of cwd
                    if relParentPath:find("^%./") then
                        relParentPath = relParentPath:sub(3) -- Remove leading ./
                    end

                    -- Return filename with relative parent path
                    return name .. " - " .. relParentPath
                end,
            },
        },
    },
})

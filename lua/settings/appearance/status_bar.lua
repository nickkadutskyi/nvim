local spec_builder = require("ide.spec.builder")
local pack = require("ide.pack")
local utils = require("ide.utils")

--- AUTOCMDS -------------------------------------------------------------------

utils.run.now_if_arg_or_deferred(function()
    -- Setup autocmds to update buffer_modified_count when relevant events occur
    utils.autocmd.create({ "BufWritePost", "BufEnter", "BufModifiedSet", "FileChangedShellPost" }, {
        callback = function()
            _G._buffer_modified_last_check_time = 0
        end,
        desc = "Reset buffer modified check timer for status line updates.",
    })
end)

--- PLUGINS --------------------------------------------------------------------

spec_builder.add({
    "kristoferssolo/lualine-harpoon.nvim",
    opts = {
        -- Configure symbols used in the display
        symbol = {
            -- open = "[",
            open = "",
            -- close = "]",
            close = "",
            separator = "/",
            unknown = "?",
        },
        -- Icon displayed before the harpoon status
        icon = "",
        -- icon = "",
        -- Show component even when there are no harpoon marks
        show_when_empty = false,
        -- Custom format function (overrides default formatting)
        -- format = function(current, total)
        --     return string.format("Harpoon: %s/%d", current or "?", total)
        -- end,
        -- Cache timeout in milliseconds for performance
        cache_timeout = 100,
    },
})

spec_builder.add({
    "nvim-lualine/lualine.nvim",
    opts = {
        options = {
            globalstatus = true, -- sets vim.o.laststatus to 3, making the status line global
            component_separators = { left = "", right = "" },
            section_separators = { left = "", right = "" },
            always_divide_middle = true,
        },
        sections = {
            lualine_a = {}, -- Used this for project abbreviation
            lualine_b = {}, -- Used this for project name
            lualine_c = {
                { "nav_bar", padding = { left = 1, right = 0 } },
                {
                    "filetype",
                    padding = { left = 0, right = 0 },
                    icon_only = true,
                    fmt = function(filetype, _)
                        -- forces to use the default filetype icon
                        return filetype ~= "" and filetype or " "
                    end,
                },
                { -- Provides file name
                    "filename",
                    path = 0,
                    padding = { left = 0, right = 0 },
                    file_status = true,
                    newfile_status = true,
                    symbols = { newfile = "[new]", unnamed = "[no name]" },
                    color = function(_)
                        return vim.b.custom_git_status_hl or "Custom_TabSel"
                    end,
                    separator = " ›",
                },
                {
                    "navic",
                    color_correction = nil,
                    navic_opts = {
                        click = true,
                        separator = " › ",
                        highlight = true,
                    },
                },
            },
            lualine_x = {
                {
                    "lsp_progress",
                    fmt = function(str)
                        -- Should fix "E539: Illegal character <,>"  error
                        return require("lualine.utils.utils").stl_escape(str)
                    end,
                },
                {
                    -- Shows currently running linters
                    function()
                        if pack.is_loaded("nvim-lint") then
                            local linters = require("lint").get_running()
                            linters = vim.tbl_map(function(linter)
                                return " " .. linter
                            end, linters)

                            return #linters > 0 and table.concat(linters, " ") or ""
                        end
                        return ""
                    end,
                },
                { Utils.lualine.component_macro_recording },
                { "harpoon" },
                {
                    Utils.lualine.gitstat_subsec_has_unsaved_buffers,
                    color = "StatusBarHasUnsavedBuffers",
                    padding = { left = 0, right = 1 },
                },
            },
            lualine_y = {
                {
                    "branch",
                    icon = "󰘬",
                    padding = { left = 1, right = 1 },
                    cond = function()
                        return not require("lualine.components.jujutsu").is_jujutsu_repo()
                    end,
                },
                { "jujutsu" },
                { "searchcount", padding = { left = 0, right = 1 } },
                { "location", padding = { left = 0, right = 1 } },
            },
            lualine_z = {
                {
                    "mode",
                    fmt = function(mode)
                        -- Shortened mode names
                        local modes = {
                            ["NORMAL"] = "NO", -- Normal mode
                            ["O-PENDING"] = "OP", -- Operator-pending (e.g., after 'd', 'c', etc.)
                            ["VISUAL"] = "VI", -- Visual char-wise
                            ["V-LINE"] = "VL", -- Visual line-wise
                            ["V-BLOCK"] = "VB", -- Visual block-wise
                            ["SELECT"] = "SE", -- Select char-wise
                            ["S-LINE"] = "SL", -- Select line-wise
                            ["S-BLOCK"] = "SB", -- Select block-wise
                            ["INSERT"] = "IN", -- Insert mode
                            ["REPLACE"] = "RE", -- Replace mode
                            ["V-REPLACE"] = "VR", -- Virtual Replace mode
                            ["COMMAND"] = "CL", -- Command-line mode
                            ["EX"] = "Ex", -- Ex mode (rare)
                            ["MORE"] = "MO", -- More prompt (e.g., -- More --)
                            ["CONFIRM"] = "??", -- Confirmation prompt
                            ["SHELL"] = "Sh", -- Shell command (via :!)
                            ["TERMINAL"] = "TE", -- Terminal-Job mode
                        }
                        return modes[mode] or mode
                    end,
                },
            },
        },
        -- No sections in inactive status lines since we
        inactive_sections = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = {},
            lualine_x = {},
            lualine_y = {},
            lualine_z = {},
        },
    },
})

local buffer_modified_count = 0
local last_check_time = 0

-- Setup autocmds to update buffer_modified_count when relevant events occur
vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "BufModifiedSet", "FileChangedShellPost" }, {
    callback = function()
        -- Reset the timer to force an update on the next status line refresh
        last_check_time = 0
    end,
})

return {
    { -- Provides better keymap for macro recording
        "chrisgrieser/nvim-recorder",
        ---@type configObj
        ---@diagnostic disable-next-line: missing-fields
        opts = { lessNotifications = true, clear = true, dynamicSlots = "rotate" },
    },
    { -- Status bar controller
        "nvim-lualine/lualine.nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            "arkav/lualine-lsp-progress",
            "AndreM222/copilot-lualine",
            "chrisgrieser/nvim-recorder",
        },
        config = function()
            local utils = require("lualine.utils.utils")
            local opts = {
                options = {
                    globalstatus = true,
                    component_separators = { left = "", right = "" },
                    section_separators = { left = "", right = "" },
                    always_divide_middle = true,
                },
                sections = {
                    lualine_a = {
                        { require("kdtsk.utils").project_abbreviation },
                    },
                    lualine_b = {
                        "branch",
                        {
                            "gitstatus",
                            sections = {
                                { -- Shows a red icon if there are unsaved buffers
                                    function(_)
                                        local current_time = vim.loop.now()
                                        if current_time - last_check_time > 500 then
                                            local count, _ = require("kdtsk.utils").count_modified_buffers()
                                            buffer_modified_count = count
                                        end
                                        last_check_time = current_time

                                        if buffer_modified_count > 0 then
                                            return "󰽃"
                                        end
                                    end,
                                    hl = "#f7768e",
                                },
                                { -- Shows a delta icon if there are uncommitted changes
                                    function(status)
                                        if buffer_modified_count > 0 then
                                            return false
                                        end
                                        if status.is_dirty or status.staged > 0 then
                                            return "Δ"
                                        else
                                            return "∅"
                                        end
                                    end,
                                },
                                { "ahead", format = " {}↑", hl = "General_Text_DefaultTextFg" },
                                { "behind", format = " {}↓", hl = "General_Text_DefaultTextFg" },
                            },
                            sep = "",
                        },
                    },
                    lualine_c = {
                        {
                            "filetype",
                            padding = { left = 1, right = 0 },
                            icon_only = true,
                        },
                        {
                            "filename",
                            file_status = true,
                            newfile_status = true,
                            path = 1, -- Show relative path
                            symbols = { newfile = "[new]", unnamed = "[no name]" },
                            fmt = function(name, _)
                                -- Early return for terminal buffers
                                if name:find("^term://") then
                                    local path_parts = vim.fn.split(vim.fn.expand("%"), ":")
                                    local last = path_parts[#path_parts]
                                    if type(last) == "string" and last ~= "" then
                                        return "term " .. last
                                    end
                                    return "terminal"
                                end

                                -- Split the name into path and status indicators (like [+], [RO], etc.)
                                local filePath, rest = name:match("(.+)%s*(%[*.*%]*)")
                                if not filePath then
                                    return name -- Handle edge cases where matching fails
                                end

                                -- Calculate the threshold for shortening based on screen width
                                local shorten_after = math.floor(vim.o.columns / 238 * 70)

                                -- Only do expensive operations if shortening is needed
                                if #filePath <= shorten_after then
                                    return filePath .. " " .. (rest or "")
                                end

                                -- Caching the fileName to avoid repeated calls
                                local fileName = vim.fs.basename(filePath)
                                local parentPath = vim.fn.fnamemodify(filePath, ":h")
                                local parentName = vim.fs.basename(parentPath)

                                -- Create the shortened path
                                local rightPart = parentName .. "/" .. fileName
                                local leftPartLen = shorten_after - #rightPart - 3 -- account for "../"
                                leftPartLen = math.max(0, leftPartLen) -- ensure non-negative

                                local leftPart = filePath:sub(1, leftPartLen)
                                return leftPart .. "../" .. rightPart .. " " .. (rest or "")
                            end,
                            color = function(_)
                                return vim.b.custom_git_status_hl or "Custom_TabSel"
                            end,
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
                                -- Should fix "E539: Illegal character <,>" error
                                return utils.stl_escape(str)
                            end,
                        },
                        { -- Macro recording status
                            function()
                                local reg = vim.fn.reg_recording()
                                return reg ~= "" and " [" .. reg .. "]" or ""
                            end,
                        },
                        { "diagnostics" },
                        { "copilot" },
                    },
                    lualine_y = {
                        { require("recorder").displaySlots },
                        "searchcount",
                        "location",
                    },
                    lualine_z = {
                        {
                            "mode",
                            fmt = function(mode)
                                local modes = {
                                    ["NORMAL"] = "NORM",
                                    ["O-PENDING"] = "OPND",
                                    ["VISUAL"] = "VISU",
                                    ["V-LINE"] = "VISL",
                                    ["V-BLOCK"] = "VISB",
                                    ["SELECT"] = "SELE",
                                    ["S-LINE"] = "SELL",
                                    ["S-BLOCK"] = "SELB",
                                    ["INSERT"] = "INSE",
                                    ["REPLACE"] = "RPLC",
                                    ["V-REPLACE"] = "VRPL",
                                    ["COMMAND"] = "COMM",
                                    ["EX"] = "ExEC",
                                    ["MORE"] = "MORE",
                                    ["CONFIRM"] = "CONF",
                                    ["SHELL"] = "SHEL",
                                    ["TERMINAL"] = "TERM",
                                }
                                return modes[mode] or mode
                            end,
                        },
                    },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = {},
                    lualine_x = {},
                    lualine_y = {},
                    lualine_z = {},
                },
            }
            require("lualine").setup(opts)
        end,
    },
}

-- Setup autocmds to update buffer_modified_count when relevant events occur
vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "BufModifiedSet", "FileChangedShellPost" }, {
    callback = function()
        -- Reset the timer to force an update on the next status line refresh
        _G._buffer_modified_last_check_time = 0
    end,
})

return {
    { -- Status bar controller
        "nvim-lualine/lualine.nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            "arkav/lualine-lsp-progress",
        },
        config = function()
            _G._buffer_modified_count = 0
            _G._buffer_modified_last_check_time = 0

            local utils = require("lualine.utils.utils")
            ---@type user_config
            local opts = {
                options = {
                    globalstatus = true,
                    component_separators = { left = "", right = "" },
                    section_separators = { left = "", right = "" },
                    always_divide_middle = true,
                },
                sections = {
                    lualine_a = {
                        { Utils.lualine.project_abbreviation },
                    },
                    lualine_b = {
                        { "branch", padding = { left = 1, right = 0 } },
                        {
                            "gitstatus",
                            sections = {
                                { Utils.lualine.gitstat_subsec_has_unsaved_buffers, hl = "StatusBarHasUnsavedBuffers" },
                                { Utils.lualine.gitstat_subsec_is_clean, hl = "GitToolBoxColorsIconsClean" },
                                { Utils.lualine.gitstat_subsec_is_dirty, hl = "GitToolBoxColorsIconsDirty" },
                                { "ahead", format = " {}↑", hl = "GitToolBoxColorsIconsClean" },
                                { "behind", format = " {}↓", hl = "GitToolBoxColorsIconsClean" },
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
                        { Utils.lualine.component_macro_recording },
                        { "diagnostics" },
                    },
                    lualine_y = {
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

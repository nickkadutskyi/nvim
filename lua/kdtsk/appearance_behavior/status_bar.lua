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
                        { -- Project abbreviation
                            function()
                                local projectName = vim.fs.basename(vim.fn.getcwd())
                                local firstChars = {}
                                for str in string.gmatch(projectName, "([^-_,%s.]+)") do
                                    table.insert(firstChars, string.upper(string.sub(str, 1, 1)))
                                end
                                return (firstChars[1] or "")
                                    .. (
                                        #firstChars > 1 and firstChars[#firstChars]
                                        or string.upper(string.sub(projectName, 2, 2))
                                        or ""
                                    )
                            end,
                        },
                    },
                    lualine_b = {
                        "branch",
                        {
                            "gitstatus",
                            sections = {
                                {
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
                                {
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
                                {
                                    function(status)
                                        return status.ahead > 0 and " " .. status.ahead .. "↑" or false
                                    end,
                                    hl = "General_Text_DefaultTextFg",
                                },
                                {
                                    function(status)
                                        return status.behind > 0 and status.behind .. "↓" or false
                                    end,
                                    hl = "General_Text_DefaultTextFg",
                                },
                            },
                            sep = "",
                        },
                    },
                    lualine_c = {
                        -- "diff",
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
                                local filePath, rest = name:match("(.+)%s*(%[*.*%]*)")
                                local parentPath = vim.fn.fnamemodify(filePath, ":h")
                                local fileName = vim.fs.basename(filePath)

                                if string.match(name, "term://.*") then
                                    local path_parts = vim.fn.split(vim.fn.expand("%"), ":")
                                    local last = path_parts[#path_parts]
                                    if type(last) == "string" and last ~= "" then
                                        return last and "term " .. last
                                    end
                                end

                                local shorten_after = math.floor(vim.o.columns / 238 * 70)
                                if string.len(filePath) > shorten_after then
                                    local rightPart = vim.fs.basename(parentPath) .. "/" .. fileName
                                    local leftPart = string.sub(filePath, 1, shorten_after - string.len(rightPart))
                                    return leftPart .. "../" .. rightPart .. " " .. (rest or "")
                                else
                                    return filePath .. " " .. (rest or "")
                                end
                            end,
                            color = function(_)
                                return vim.b.custom_git_status_hl or "Custom_TabSel"
                            end,
                        },
                        {
                            "navic",
                            -- Component specific options

                            -- Can be nil, "static" or "dynamic". This option
                            -- is useful only when you have highlights enabled.
                            -- Many colorschemes don't define same backgroud for
                            -- nvim-navic as their lualine statusline backgroud.
                            -- Setting it to "static" will perform an adjustment
                            -- once when the component is being setup. This should
                            -- be enough when the lualine section isn't changing
                            -- colors based on the mode.
                            -- Setting it to "dynamic" will keep updating the
                            -- highlights according to the current modes colors
                            -- for the current section.
                            color_correction = nil,

                            navic_opts = {
                                click = true,
                                separator = " › ",
                                highlight = true,
                            }, -- lua table with same format as setup's option. All options except "lsp" options take effect when set here.
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
                        -- "progress",
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

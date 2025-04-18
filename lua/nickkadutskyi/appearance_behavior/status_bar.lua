local buffer_modified_count = 0
local function count_modified_buffers()
    local buffersUnfiltered = vim.api.nvim_list_bufs()
    local unsaved = 0
    local new_unsaved = 0
    local new_buffers = 0
    local total_buffers = 0
    for _, buffer in ipairs(buffersUnfiltered) do
        -- ensure only listed and loaded buffers are counted
        if vim.api.nvim_get_option_value("buflisted", { buf = buffer }) and vim.api.nvim_buf_is_loaded(buffer) then
            local is_modified = vim.api.nvim_get_option_value("modified", { buf = buffer })
            local line_count = vim.api.nvim_buf_line_count(buffer)
            local filename = vim.api.nvim_buf_get_name(buffer)
            local filetype = vim.api.nvim_get_option_value("filetype", { buf = buffer })
            local cwd = vim.fn.getcwd()
            local filename_resolved = vim.fn.resolve(filename)
            local is_modifiable = vim.api.nvim_get_option_value("modifiable", { buf = buffer })
            -- Skip special buffers and the initial empty unmodified buffer
            if
                filetype ~= "qf"
                and filetype ~= "help"
                and filetype ~= "NvimTree"
                and filetype ~= "fzf"
                and filetype ~= "netrw"
                and is_modifiable
                and not (filename_resolved == cwd and not is_modified and line_count <= 1)
            then
                total_buffers = total_buffers + 1
                if is_modified then
                    if filename == "" then
                        -- Unnamed buffer that's been modified
                        new_unsaved = new_unsaved + 1
                        buffer_modified_count = unsaved + new_unsaved + new_buffers
                    else
                        -- Existing file with unsaved changes
                        unsaved = unsaved + 1
                    end
                elseif filename ~= "" and not vim.loop.fs_stat(filename) then
                    -- Buffer has a name but file doesn't exist on disk yet
                    new_buffers = new_buffers + 1
                end
            end
        end
    end
    buffer_modified_count = unsaved + new_unsaved + new_buffers
end
return {
    {
        "chrisgrieser/nvim-recorder",
        opts = {}, -- required even with default settings, since it calls `setup()`
    },
    { -- Status bar controller
        "nvim-lualine/lualine.nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            "akinsho/toggleterm.nvim",
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
                        -- keep account, code and project name in tab title
                        -- { -- Project name
                        --     function()
                        --         local cwd = vim.fn.getcwd()
                        --         -- local devpath = vim.fn.fnamemodify("~/Developer", ":p")
                        --
                        --         -- if cwd:find(devpath, 1, true) == 1 then
                        --         --     local name = vim.fs.basename(cwd)
                        --         --     local code = vim.fs.basename(vim.fs.dirname(cwd))
                        --         --     local account = vim.fs.basename(vim.fs.dirname(vim.fn.fnamemodify(cwd, ":h")))
                        --         --
                        --         --     return account .. "" .. (tonumber(code) or code) .. " " .. name
                        --         -- else
                        --         return vim.fs.basename(cwd)
                        --         -- end
                        --     end,
                        -- },
                        "branch",
                        {
                            "gitstatus",
                            sections = {
                                {
                                    function(_status)
                                        count_modified_buffers()
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
                                { "conflicted", format = " {}!" },
                                { "staged", format = " {}=" },
                                { "untracked", format = " {}+" },

                                { "modified", format = " {}*" },
                                { "renamed", format = " {}~" },
                                { "deleted", format = " {}-" },

                                {
                                    function(status)
                                        return status.ahead == 0 and " ·↑" or false
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
                                        return status.behind == 0 and "·↓" or false
                                    end,
                                },
                                {
                                    function(status)
                                        return status.behind > 0 and status.behind .. "↓" or false
                                    end,
                                    hl = "General_Text_DefaultTextFg",
                                },
                                -- { "ahead", format = "{}↑" },
                                -- { "behind", format = "{}↓" },
                                -- { "up_to_date", format = "up-to-date" },
                                -- { "up_to_date", format = "↑0↓0" },
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

                                if string.match(name, "term://.*toggleterm#.*") then
                                    local terms = require("toggleterm.terminal").get_all()
                                    local term = require("toggleterm.terminal").get(tonumber(vim.b.toggle_number))
                                    local termid = term and term.id or ""
                                    local termname = term and termid .. ": " .. (term:_display_name()) or ""
                                    return "term " .. termname .. " (" .. #terms .. ") " .. (rest or "")
                                end
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
                            color_correction = "dynamic", -- Can be nil, "static" or "dynamic". This option is useful only when you have highlights enabled.
                            -- Many colorschemes don't define same backgroud for nvim-navic as their lualine statusline backgroud.
                            -- Setting it to "static" will perform a adjustment once when the component is being setup. This should
                            --   be enough when the lualine section isn't changing colors based on the mode.
                            -- Setting it to "dynamic" will keep updating the highlights according to the current modes colors for
                            --   the current section.

                            navic_opts = {
                                click = true,
                                separator = "  ",
                                highlight = true,
                            }, -- lua table with same format as setup's option. All options except "lsp" options take effect when set here.
                        },
                    },
                    lualine_x = {
                        { require("recorder").recordingStatus },
                        {
                            "lsp_progress",
                            fmt = function(str)
                                -- Should fix "E539: Illegal character <,>" error
                                return utils.stl_escape(str)
                            end,
                        },
                        { "copilot" },
                        { "diagnostics" },
                        {
                            "overseer",
                            label = "", -- Prefix for task counts
                            colored = true, -- Color the task icons and counts
                            unique = false, -- Unique-ify non-running task count by name
                            name = nil, -- List of task names to search for
                            name_not = false, -- When true, invert the name search
                            status = nil, -- List of task statuses to display
                            status_not = false, -- When true, invert the status search
                        },
                    },
                    lualine_y = {
                        { require("recorder").displaySlots },
                        "searchcount",
                        "progress",
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

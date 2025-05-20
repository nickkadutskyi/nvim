-- Setup autocmds to update buffer_modified_count when relevant events occur
vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "BufModifiedSet", "FileChangedShellPost" }, {
    callback = function()
        -- Reset the timer to force an update on the next status line refresh
        _G._buffer_modified_last_check_time = 0
    end,
})

return {
    { -- Status bar controller in the top right corner
        -- TODO: Consider adding number of misspelled words
        "b0o/incline.nvim",
        config = function()
            require("incline").setup({
                render = function(props)
                    return {
                        { Utils.incline.component_diagnostics(props) },
                    }
                end,
            })
        end,
        -- Optional: Lazy load Incline
        event = "VeryLazy",
    },
    { -- Status bar controller in status line
        "nvim-lualine/lualine.nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            "arkav/lualine-lsp-progress",
        },
        config = function()
            _G._buffer_modified_count = 0
            _G._buffer_modified_last_check_time = 0

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
                        { Utils.lualine.project_abbreviation },
                    },
                    lualine_b = {
                        { "branch", icon = "󰘬", padding = { left = 1, right = 0 } },
                        {
                            "gitstatus",
                            padding = { left = 0, right = 2 },
                            sections = {
                                { "behind", format = " 󰦸", hl = "VCSIconsUnpulled" },
                                { "ahead", format = " 󰧆 ", hl = "VCSIconsUnmerged" },
                                { Utils.lualine.gitstat_subsec_has_unsaved_buffers, hl = "StatusBarHasUnsavedBuffers" },
                                { Utils.lualine.gitstat_subsec_is_clean, hl = "GitToolBoxColorsIconsClean" },
                                { Utils.lualine.gitstat_subsec_is_dirty, hl = "GitToolBoxColorsIconsDirty" },
                            },
                            sep = "",
                        },
                    },
                    lualine_c = {
                        -- { "nav_bar" },
                        -- TODO add current module name here
                        { -- Provides parent path relative to the cwd
                            "filename",
                            path = 1,
                            file_status = false,
                            newfile_status = false,
                            fmt = function(name, _)
                                local parent_path = vim.fn.fnamemodify(name, ":h")

                                -- If terminal buffer, get the last part of the path
                                if name:find("^term://") then
                                    local path_parts = vim.fn.split(vim.fn.expand("%"), ":")
                                    local last = path_parts[#path_parts]
                                    if type(last) == "string" and last ~= "" then
                                        parent_path = vim.fn.fnamemodify(last, ":h")
                                    else
                                        parent_path = "terminal"
                                    end
                                end

                                local parent_path_sep = parent_path:gsub("%/", " › ")
                                return parent_path_sep
                            end,
                            padding = { left = 0, right = 1 },
                            separator = "›",
                        },
                        {
                            "filetype",
                            padding = { left = 1, right = 0 },
                            icon_only = true,
                            fmt = function(filetype, _)
                                -- forces to use the default filetype icon
                                return filetype ~= "" and filetype or " "
                            end,
                        },
                        { -- Provides file name
                            "filename",
                            path = 0,
                            padding = { left = 0, right = 1 },
                            file_status = true,
                            newfile_status = true,
                            symbols = { newfile = "[new]", unnamed = "[no name]" },
                            color = function(_)
                                return vim.b.custom_git_status_hl or "Custom_TabSel"
                            end,
                            separator = "›",
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

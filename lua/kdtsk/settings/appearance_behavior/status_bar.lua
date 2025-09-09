-- Setup autocmds to update buffer_modified_count when relevant events occur
vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "BufModifiedSet", "FileChangedShellPost" }, {
    callback = function()
        -- Reset the timer to force an update on the next status line refresh
        _G._buffer_modified_last_check_time = 0
    end,
})

return {
    { -- Status bar controller in the top right corner
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
                        -- { Utils.lualine.project_abbreviation },
                    },
                    lualine_b = {},
                    lualine_c = {
                        { "nav_bar" },
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
                                return utils.stl_escape(str)
                            end,
                        },
                        {
                            -- Shows currently running linters
                            function()
                                local linters = require("lint").get_running()
                                linters = vim.tbl_map(function(linter)
                                    return " " .. linter
                                end, linters)

                                return #linters > 0 and table.concat(linters, " ") or ""
                            end,
                        },
                        { Utils.lualine.component_macro_recording },
                        {
                            "harpoon2",
                            icon = "",
                            -- Plain numbers
                            -- indicators = { "①", "②", "③", "④", "⑤", "⑥", "⑦", "⑧" },
                            -- active_indicators = { "➊", "➋", "➌", "➍", "➎", "➏", "➐", "➑" },
                            -- Nerd font icons
                            indicators = { "󰲡", "󰲣", "󰲥", "󰲧", "󰲩", "󰲫", "󰲭", "󰲯" },
                            active_indicators = { "󰲠", "󰲢", "󰲤", "󰲦", "󰲨", "󰲪", "󰲬", "󰲮" },
                            _separator = " ",
                            no_harpoon = "Harpoon not loaded",
                        },
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

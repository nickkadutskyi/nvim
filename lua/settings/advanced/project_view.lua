local spec = require("ide.spec.builder")

spec.add({
    "snacks.nvim",
    opts = {
        explorer = {
            enabled = true,
            replace_netrw = true,
        },
        ---@class snacks.picker.Config
        picker = {
            sources = {
                ---@type snacks.picker.explorer.Config|{}
                explorer = {
                    auto_close = true,
                    title = "Project",
                    hidden = true,
                    ignored = true,
                    win = {
                        list = {
                            keys = {
                                ["<M-CR>"] = "tab",
                                ["<C-t>"] = "tab",
                            },
                        },
                    },
                    formatters = {
                        file = {
                            filename_first = false, -- display filename before the file path
                            truncate = 40, -- truncate the file path to (roughly) this length
                            filename_only = false, -- only show the filename
                            icon_width = 4, -- width of the icon (in characters)
                            icon_align_opts = { align = "right" },
                            git_status_hl = true, -- use the git status highlight group for the filename
                        },
                    },
                    icons = {
                        files = {
                            enabled = true, -- show file icons
                            dir = " ",
                            dir_open = " ",
                            file = "",
                        },
                        tree = {
                            vertical = "│",
                            middle = "│",
                            last = "│",
                        },
                    },
                    layouts = {
                        sidebar_float = {
                            preview = "main",
                            layout = {
                                backdrop = false,
                                width = 40,
                                min_width = 40,
                                height = 0,
                                col = 0,
                                row = 0,
                                position = "float",
                                -- border = "none",
                                border = {
                                    "",
                                    "",
                                    { "▕", "ToolWindowFloatBorder" },
                                    { "▕", "ToolWindowFloatBorder" },
                                    { "▕", "ToolWindowFloatBorder" },
                                    { " ", "ToolWindowFloatBorder" },
                                    { " ", "ToolWindowFloatBorder" },
                                    "",
                                },
                                box = "vertical",
                                {
                                    box = "vertical",
                                    {
                                        win = "input",
                                        height = 1,
                                        border = { "", " ", "", "", "", "", "", "" }, -- only top border for title
                                        title = "{title} {live} {flags}",
                                        title_pos = "left",
                                    },
                                    { win = "list", border = "none" },
                                    { win = "preview", title = "{preview}", height = 0.4, border = "top" },
                                },
                            },
                        },
                    },
                    layout = {
                        preset = "sidebar_float",
                    },
                },
            },
        },
    },
})

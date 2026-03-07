---@type LazySpec
return {
    { -- Visual guides
        "lukas-reineke/virt-column.nvim",
        opts = {
            -- Highlight groups from kdtsk/jb.nvim
            highlight = {
                "General_Editor_Guides_VisualGuides",
                "General_Editor_Guides_VisualGuides",
                "General_Editor_Guides_HardWrapGuide",
            },
            char = "▕",
            virtcolumn = "80,100,120",
            exclude = { filetypes = { "netrw" } },
        },
    },
    { -- Indent guides
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        opts = {
            indent = { char = "▏", tab_char = "▏" },
            -- disables underline
            scope = { char = "▏", show_start = false, show_end = false },
        },
    },
    { -- Error stripes and VCS status in Scrollbar
        "petertriho/nvim-scrollbar",
        dependencies = {
            "kevinhwang91/nvim-hlslens",
        },
        opts = {
            show = true,
            set_highlights = false,
            hide_if_all_visible = false,
            handlers = {
                diagnostic = true,
                gitsigns = true, -- Requires gitsigns
                handle = true,
                search = true, -- Requires hlslens
                cursor = false,
            },
            excluded_filetypes = { "snacks_picker_list" },
            marks = {
                GitAdd = {
                    text = "│",
                },
                GitChange = {
                    text = "│",
                },
                IdentifierUnderCaret = {
                    text = { "-", "=" },
                    priority = 1,
                    gui = nil,
                    color = nil,
                    cterm = nil,
                    color_nr = nil, -- cterm
                    highlight = "IdentifierUnderCaret",
                },
                Todo = {
                    text = { "-", "=" },
                    priority = 1,
                    gui = nil,
                    color = nil,
                    cterm = nil,
                    color_nr = nil, -- cterm
                    highlight = "Todo",
                },
            },
        },
        config = function(_, opts)
            require("scrollbar").setup(opts)
            require("scrollbar.handlers").register("under_caret", function(bufnr)
                return vim.g.highlighted_lines or {}
            end)
            require("scrollbar.handlers").register("todo", function(bufnr)
                return (vim.g.todos_in_files or {})[vim.api.nvim_buf_get_name(bufnr)] or {}
            end)
        end,
    },
}

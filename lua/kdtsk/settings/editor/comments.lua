return {
    {
        -- Improves commenting
        "numToStr/Comment.nvim",
        opts = {},
    },
    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {
            signs = false, -- show icons in the signs column
            sign_priority = 8, -- sign priority
            -- keywords recognized as todo comments
            keywords = {
                FIX = {
                    icon = " ", -- icon used for the sign, and in search results
                    color = "error", -- can be a hex color, or a named color (see below)
                    alt = { "FIXME", "BUG", "FIXIT", "ISSUE", "ERROR" },
                    -- signs = false, -- configure signs for some keywords individually
                },
                TODO = { icon = " ", color = "info" },
                HACK = { icon = " ", color = "warning" },
                WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
                PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
                NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
            },
            gui_style = {
                fg = "NONE", -- The gui style to use for the fg highlight group.
                bg = "BOLD", -- The gui style to use for the bg highlight group.
            },
            merge_keywords = true, -- when true, custom keywords will be merged with the defaults
            -- highlighting of the line containing the todo comment
            -- * before: highlights before the keyword (typically comment characters)
            -- * keyword: highlights of the keyword
            -- * after: highlights after the keyword (todo text)
            highlight = {
                -- "fg" or "bg" or empty
                before = "",
                -- "fg", "bg", "wide", "wide_bg", "wide_fg" or empty. (wide and
                -- wide_bg is the same as bg, but will also highlight surrounding
                -- characters, wide_fg acts accordingly but with fg)
                keyword = "fg",
                -- "fg" or "bg" or empty
                after = "",

                -- pattern or table of patterns, used for highlighting (vim regex)
                pattern = { [[.*<(KEYWORDS)\s*:]] },
            },
            -- list of named colors where we try to extract the guifg from the
            -- list of highlight groups or use the hex color if hl not found as a fallback
            colors = {
                error = { "@comment.error.comment" },
                warning = { "@comment.warning.comment" },
                info = { "@comment.todo.comment" },
                hint = { "@comment.note.comment" },
                default = { "@comment.note.comment" },
            },
            search = {
                command = "rg",
                args = {
                    "--color=never",
                    "--no-heading",
                    "--with-filename",
                    "--line-number",
                    "--column",
                },
                -- regex that will be used to match keywords.
                -- don't replace the (KEYWORDS) placeholder
                pattern = [[\b(KEYWORDS):]], -- ripgrep regex
                -- Matches both with and without the colon
                -- pattern = [[\b(KEYWORDS)(:|\b)]], -- ripgrep regex
                -- pattern = [[\b(KEYWORDS)\b]], -- match without the extra colon. You'll likely get false positives
            },
        },
        config = function(_, opts)
            require("todo-comments").setup(opts)

            -- Keymap for navigating todo comments
            vim.keymap.set("n", "]t", require("todo-comments").jump_next, { desc = "TODO: Next todo comment" })
            vim.keymap.set("n", "[t", require("todo-comments").jump_prev, { desc = "TODO: Previous todo comment" })
        end,
    },
}

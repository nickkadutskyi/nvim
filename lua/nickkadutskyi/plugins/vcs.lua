return {
    {
        -- Git integration
        -- FIXME resolve issue with headers when using split kind for log_view https://github.com/NeogitOrg/neogit/issues/1540
        -- TODO test
        "NeogitOrg/neogit",
        dependencies = {
            "nvim-lua/plenary.nvim", -- required
            "sindrets/diffview.nvim", -- optional - Diff integration
            "ibhagwan/fzf-lua", -- optional
        },
        config = function()
            local neogit = require("neogit")
            neogit.setup({
                process_spinner = false,
                integrations = {
                    fzf_lua = true,
                    diffview = true,
                },
                signs = {
                    -- { CLOSED, OPENED }
                    hunk = { "", "" },
                    item = { " ", " " },
                    section = { "", "" },
                },
                status = {
                    mode_padding = 2,
                    -- adds whitespace to the left of the mode text to put it further from sings and makes it shorter
                    mode_text = {
                        M = " mod",
                        N = " new",
                        A = " add",
                        D = " del",
                        C = " cop",
                        U = " upd",
                        R = " ren",
                        DD = " unm",
                        AU = " unm",
                        UD = " unm",
                        UA = " unm",
                        DU = " aunm",
                        AA = " unm",
                        UU = " unm",
                        ["?"] = " ",
                    },
                },
            })

            for lhs, mode in pairs({
                ["<leader>avc"] = { "n" },
                ["<A-K>"] = { { "n", "i" } }, -- Similar to Intellij <CMD-K>
                ["˚"] = { { "n", "i" } }, -- macOS char for the <A-K> key
                ["<leader>ac"] = { "n", "VCS: [a]ctivate vcs [c]ommit window" },
            }) do
                vim.keymap.set(mode[1], lhs, function()
                    vim.cmd("CloseNetrw")
                    vim.cmd("CloseNetrw")
                    neogit.open()
                end, { noremap = true, desc = mode[2] or "VCS: [a]ctivate [v]cs [c]ommit window" })
            end

            vim.keymap.set("n", "<leader>avf", function()
                vim.cmd("CloseNetrw")
                vim.cmd("CloseNetrw")
                neogit.action("log", "log_current", { "--", vim.fn.expand("%") })()
            end, { noremap = true, desc = "VCS: [a]ctivate [v]sc log for current [f]ile" })

            vim.keymap.set("n", "<leader>avl", function()
                vim.cmd("CloseNetrw")
                vim.cmd("CloseNetrw")
                neogit.action("log", "log_head")()
            end, { noremap = true, desc = "VCS: [a]ctivate [v]sc [l]og" })

            for lhs, mode in pairs({
                ["<leader>avP"] = "n",
                ["<S-A-K>"] = { "n", "i" }, -- Similar to Intellij <D-S-K>
                [""] = { "n", "i" }, -- macOS char for the <S-A-K> key
            }) do
                vim.keymap.set(mode, lhs, function()
                    vim.cmd("CloseNetrw")
                    vim.cmd("CloseNetrw")
                    neogit.open({ "push" })
                end, { noremap = true, desc = "VCS: [a]ctivate [v]cs [p]ush window" })
            end

            for lhs, mode in pairs({
                ["<leader>avp"] = "n",
                ["<A-T>"] = { "n", "i" }, -- Similar to Intellij <D-T>
                ["†"] = { "n", "i" }, -- macOS char for the <A-T> key
            }) do
                vim.keymap.set(mode, lhs, function()
                    vim.cmd("CloseNetrw")
                    vim.cmd("CloseNetrw")
                    neogit.open({ "pull" })
                end, { noremap = true, desc = "VCS: [a]ctivate [v]cs [p]ull window" })
            end
        end,
    },
    {
        -- TODO change position of hunk float so it appears under the row and to the left
        -- TODO find out if I can use regular colors for hunk preview
        -- TODO style this plugin in jb.nvim color scheme
        -- Visibility for changes compared to current git branch in the gutter
        "lewis6991/gitsigns.nvim",
        opts = {
            signs = {
                add = { text = "┃" },
                change = { text = "┃" },
                delete = { text = "_" },
                topdelete = { text = "‾" },
                changedelete = { text = "~" },
                untracked = { text = "┆" },
            },
            signs_staged = {
                add = { text = "║" },
                change = { text = "║" },
                delete = { text = "‗" },
                topdelete = { text = "═" },
                changedelete = { text = "≈" },
                untracked = { text = "┆" },
            },
            signs_staged_enable = true,
            signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
            numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
            linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
            word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
            watch_gitdir = {
                follow_files = true,
            },
            attach_to_untracked = true,
            current_line_blame = true, -- Toggle with `:Gitsigns toggle_current_line_blame`

            current_line_blame_opts = {
                virt_text = true,
                virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
                delay = 400,
                ignore_whitespace = false,
            },
            current_line_blame_formatter = "<author>, <author_time:%m/%d/%y>, <author_time:%I:%M %p> · <summary>",
            sign_priority = 6,
            update_debounce = 100,
            status_formatter = nil, -- Use default
            max_file_length = 40000, -- Disable if file is longer than this (in lines)
            preview_config = {
                -- Options passed to nvim_open_win
                border = "single",
                style = "minimal",
                relative = "cursor",
                row = 0,
                col = 1,
            },
            -- yadm = {
            --     enable = false,
            -- },
            on_attach = function(bufnr)
                local gitsigns = require("gitsigns")

                -- Show hunk
                vim.keymap.set("n", "<leader>sh", gitsigns.preview_hunk, {
                    buffer = bufnr,
                    desc = "VCS: [s]how [h]unk",
                })

                local function map(mode, l, r, opts)
                    opts = opts or {}
                    opts.buffer = bufnr
                    vim.keymap.set(mode, l, r, opts)
                end

                -- Navigation
                -- map('n', ']c', function()
                --   if vim.wo.diff then
                --     vim.cmd.normal({ ']c', bang = true })
                --   else
                --     gitsigns.nav_hunk('next')
                --   end
                -- end)
                --
                --

                -- map('n', '[c', function()
                --   if vim.wo.diff then
                --     vim.cmd.normal({ '[c', bang = true })
                --   else
                --     gitsigns.nav_hunk('prev')
                --   end
                -- end)

                -- Actions
                map("n", "<leader>hs", gitsigns.stage_hunk)
                map("n", "<leader>hr", gitsigns.reset_hunk)
                map("v", "<leader>hs", function()
                    gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
                end)
                map("v", "<leader>hr", function()
                    gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
                end)
                map("n", "<leader>hS", gitsigns.stage_buffer)
                map("n", "<leader>hu", gitsigns.undo_stage_hunk)
                map("n", "<leader>hR", gitsigns.reset_buffer)
                map("n", "<leader>hp", gitsigns.preview_hunk)
                map("n", "<leader>hb", function()
                    gitsigns.blame_line({ full = true })
                end)
                map("n", "<leader>tb", gitsigns.toggle_current_line_blame)
                map("n", "<leader>hd", gitsigns.diffthis)
                map("n", "<leader>hD", function()
                    gitsigns.diffthis("~")
                end)
                map("n", "<leader>td", gitsigns.toggle_deleted)

                -- Text object
                map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
            end,
        },
    },
}

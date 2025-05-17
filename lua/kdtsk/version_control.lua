return {
    { -- Color Scheme
        "nvim-treesitter",
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, {
                "gitignore",
            })
        end,
    },
    { -- Quality Tools
        "nvim-lint",
        opts = function()
            local gitlint = require("lint").linters.gitlint

            gitlint.args = gitlint.args or {}

            vim.list_extend(gitlint.args, {
                -- "--staged",
                "--contrib",
                "CT1",
                "-c",
                "CT1.types=fix,feat,chore,docs,style,refactor,perf,test,revert,ci,build,wip",
                "--ignore",
                "T5,B6",
            })

            return {
                linters_by_ft = {
                    gitcommit = { "gitlint" },
                },
            }
        end,
    },
    {
        -- Git integration
        "NeogitOrg/neogit",
        -- TODO Contribute a fix for `vim.opt.cmdheight = 0` case where Neogit Popup doesnt' reach the bottom
        dependencies = {
            "nvim-lua/plenary.nvim", -- required
            "sindrets/diffview.nvim", -- optional - Diff integration
            "ibhagwan/fzf-lua", -- optional
        },
        config = function()
            local neogit = require("neogit")
            neogit.setup({
                disable_hint = true,
                disable_context_highlighting = false,
                kind = "split",
                process_spinner = false,
                integrations = {
                    fzf_lua = true,
                    diffview = true,
                },
                signs = {
                    -- { CLOSED, OPENED }
                    hunk = { "", "" },
                    item = { " ", " " },
                    section = { "", "" },
                },
                status = {
                    HEAD_folded = false,
                    mode_padding = 3,
                    -- adds whitespace to the left of the mode text to put it further from sings and makes it shorter
                    mode_text = {
                        M = " modified",
                        N = " new file",
                        A = " added",
                        D = " deleted",
                        C = " copied",
                        U = " updated",
                        R = " renamed",
                        DD = " unmerged",
                        AU = " unmerged",
                        UD = " unmerged",
                        UA = " unmerged",
                        DU = " unmerged",
                        AA = " unmerged",
                        UU = " unmerged",
                        ["?"] = " untracked",
                    },
                },
                commit_editor = {
                    kind = "split",
                    show_staged_diff = false,
                    staged_diff_split_kind = "split_above",
                    spell_check = true,
                },
                log_view = {
                    kind = "split",
                },
            })

            -- Autocmds based on Neogit events
            vim.api.nvim_create_autocmd("User", {
                pattern = "NeogitStatusRefreshed",
                callback = function()
                    require("nvim-gitstatus").update_git_status()
                end,
            })

            -- Autocmds
            ---Updates file status hl when hunks are changed
            vim.api.nvim_create_autocmd({ "User" }, {
                group = vim.api.nvim_create_augroup("kdtsk-neogit-status-gitsigns", { clear = true }),
                pattern = { "GitSignsChanged" },
                callback = function(e)
                    require("kdtsk.utils").set_git_status_hl(e.buf)
                end,
            })
            ---Updates file status hl when buffer is entered or saved
            vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "FocusGained" }, {
                group = vim.api.nvim_create_augroup("kdtsk-neogit-status", { clear = true }),
                callback = function(e)
                    require("kdtsk.utils").set_git_status_hl(e.buf)
                end,
            })
            ---Sets Normal background for Neogit editors
            vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
                group = vim.api.nvim_create_augroup("kdtsk-neogit-popup-editor", { clear = true }),
                ---Defined in Neogit
                ---https://github.com/NeogitOrg/neogit/blob/master/lua/neogit/client.lua#L101
                pattern = {
                    "COMMIT_EDITMSG",
                    "MERGE_MSG",
                    "TAG_EDITMSG",
                    "EDIT_DESCRIPTION",
                    "git%-rebase%-todo",
                },
                callback = function(_)
                    -- Is delayed to get set after Neogit sets its own colors
                    vim.fn.timer_start(1, function()
                        vim.opt_local.winhl:append("Normal:Normal")
                        vim.opt_local.winhl:append("CursorLine:NeogitCursorLineEditor")
                    end)
                end,
            })
            ---Neogit Popup adjustments
            vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
                group = vim.api.nvim_create_augroup("kdtsk-neogit-popup", { clear = true }),
                pattern = { "Neogit*" },
                callback = function(e)
                    -- Is delayed to get set after Neogit sets its own colors
                    vim.fn.timer_start(1, function()
                        if vim.fn.bufname(e.buf):match("NeogitLogView") then
                            ---Sets Special background for Neogit LogViewer
                            vim.opt_local.winhl:append("Normal:CustomNeogitLogsNormal")
                        end
                        ---Sets CursorlLine to look like selector
                        vim.opt_local.winhl:append("CursorLine:NeogitCursorLine")
                    end)
                end,
            })

            -- Keymap

            for lhs, mode in pairs({
                ["<leader>avc"] = { "n" },
                ["<A-K>"] = { { "n", "i" } }, -- Similar to Intellij <CMD-K>
                ["<leader>ac"] = { "n", "VCS: [a]ctivate vcs [c]ommit window" },
            }) do
                vim.keymap.set(mode[1], lhs, function()
                    vim.cmd("CloseProjectView")
                    local layout = vim.fn.winlayout()
                    local splits = layout[1] == "row" and #layout[2] or vim.fn.winnr("$")
                    local kind = "tab"
                    if layout[1] == "row" then
                        if vim.o.columns / (splits + 1) >= 55 then
                            kind = "vsplit_left"
                            for _ = 1, splits do
                                vim.cmd("wincmd h")
                            end
                        end
                    elseif layout[1] == "leaf" and vim.o.columns / (splits + 1) >= 55 then
                        kind = "vsplit_left"
                    end

                    neogit.open({ kind = kind })
                end, { desc = mode[2] or "VCS: [a]ctivate [v]cs [c]ommit window" })
            end

            vim.keymap.set("n", "<localleader>avl", function()
                vim.cmd("CloseProjectView")
                neogit.action("log", "log_all_references", {
                    "--graph",
                    "--color",
                    "--show-signature",
                    "--decorate",
                    "--",
                    vim.fn.expand("%"),
                })()
            end, { noremap = true, desc = "VCS: [a]ctivate [v]sc log for current [f]ile" })

            vim.keymap.set("n", "<leader>avl", function()
                vim.cmd("CloseProjectView")
                neogit.action("log", "log_all_references", {
                    "--graph",
                    "--color",
                    "--show-signature",
                    "--decorate",
                })()
            end, { noremap = true, desc = "VCS: [a]ctivate [v]sc [l]og" })

            for lhs, mode in pairs({
                ["<leader>avP"] = "n",
                ["<S-A-K>"] = { "n", "i" }, -- Similar to Intellij <D-S-K>
                [""] = { "n", "i" }, -- macOS char for the <S-A-K> key
            }) do
                vim.keymap.set(mode, lhs, function()
                    vim.cmd("CloseProjectView")
                    neogit.open({ "push" })
                end, { noremap = true, desc = "VCS: [a]ctivate [v]cs [p]ush window" })
            end

            for lhs, mode in pairs({
                ["<leader>avp"] = "n",
                ["<A-T>"] = { "n", "i" }, -- Similar to Intellij <D-T>
            }) do
                vim.keymap.set(mode, lhs, function()
                    vim.cmd("CloseProjectView")
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
                -- add = { text = "┃" },
                add = { text = "▐ " },
                -- change = { text = "┃" },
                change = { text = "▐ " },
                -- delete = { text = "_" },
                delete = { text = "▁" },
                -- topdelete = { text = "‾" },
                topdelete = { text = "▔" },
                changedelete = { text = "▐" },
                untracked = { text = "▐" },
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
            culhl = true,
            word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
            diff_opts = {
                internal = true,
            },
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
                map("n", "]c", function()
                    if vim.wo.diff then
                        vim.cmd.normal({ "]c", bang = true })
                    else
                        gitsigns.nav_hunk("next", { target = "all" })
                    end
                end)
                --
                --

                map("n", "[c", function()
                    if vim.wo.diff then
                        vim.cmd.normal({ "[c", bang = true })
                    else
                        gitsigns.nav_hunk("prev", { target = "all" })
                    end
                end)

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
    {
        "abccsss/nvim-gitstatus",
        event = "VeryLazy",
        ---@type GitStatusOptions
        opts = {
            --- Interval to automatically run `git fetch`, in milliseconds.
            --- Set to `false` to disable auto fetch.
            auto_fetch_interval = os.getenv("NO1P") == "1" and 30000 or false,

            --- Timeout in milliseconds for `git status` to complete before it is killed.
            git_status_timeout = 1000,

            --- Whether to show debug messages.
            debug = false,
        },
    },
}

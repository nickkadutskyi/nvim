return {
    {
        -- Color Scheme
        "nvim-treesitter",
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, {
                "gitignore",
                "gitcommit",
                "git_config",
                "git_rebase",
                "diff",
            })
        end,
    },
    {
        -- Quality Tools
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
        "sindrets/diffview.nvim",
    },
    {
        -- TODO change position of hunk float so it appears under the row and to the left
        -- TODO find out if I can use regular colors for hunk preview
        -- TODO style this plugin in jb.nvim color scheme
        -- Visibility for changes compared to current git branch in the gutter
        "lewis6991/gitsigns.nvim",
        opts = {
            signs = {
                add = { text = "▐ " },
                change = { text = "▐ " },
                delete = { text = "▁" },
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
            culhl = true,
            diff_opts = {
                internal = true,
            },
            attach_to_untracked = true,
            current_line_blame = true, -- Toggle with `:Gitsigns toggle_current_line_blame`

            current_line_blame_opts = {
                virt_text = true,
                virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
                delay = 400,
                ignore_whitespace = false,
                virt_text_priority = 100,
                use_focus = true,
            },
            current_line_blame_formatter = "<author>, <author_time:%m/%d/%y>, <author_time:%I:%M %p> · <summary>",
            preview_config = {
                -- Options passed to nvim_open_win
                border = "single",
                style = "minimal",
                relative = "cursor",
                row = 0,
                col = 1,
            },
            on_attach = function(bufnr)
                local gitsigns = require("gitsigns")

                -- Hunk Actions
                -- Previewing changes
                vim.keymap.set("n", "<localleader>hp", gitsigns.preview_hunk, {
                    buffer = bufnr,
                    desc = "VCS: [h]unk [p]review",
                })
                vim.keymap.set("n", "<localleader>hP", gitsigns.preview_hunk_inline, {
                    buffer = bufnr,
                    desc = "VCS: [h]unk [P]review inline",
                })
                -- Staging changes
                vim.keymap.set("n", "<localleader>hs", gitsigns.stage_hunk, {
                    buffer = bufnr,
                    desc = "VCS: [h]unk [s]tage",
                })
                vim.keymap.set("v", "<localleader>hs", function()
                    gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
                end, {
                    buffer = bufnr,
                    desc = "VCS: [h]unk [s]tage",
                })
                vim.keymap.set("n", "<localleader>hS", gitsigns.stage_buffer, {
                    buffer = bufnr,
                    desc = "VCS: [h]unk [S]tage buffer",
                })
                -- Resetting changes
                vim.keymap.set("n", "<localleader>hr", gitsigns.reset_hunk, {
                    buffer = bufnr,
                    desc = "VCS: [h]unk [r]eset",
                })
                vim.keymap.set("v", "<localleader>hr", function()
                    gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
                end, {
                    buffer = bufnr,
                    desc = "VCS: [h]unk [r]eset",
                })
                vim.keymap.set("n", "<localleader>hR", gitsigns.reset_buffer, {
                    buffer = bufnr,
                    desc = "VCS: [h]unk [R]eset buffer",
                })
                -- Diff between hunk and index
                vim.keymap.set("n", "<localleader>hd", gitsigns.diffthis, {
                    buffer = bufnr,
                    desc = "VCS: [h]unk [d]iff",
                })
                vim.keymap.set("n", "<localleader>hD", function()
                    gitsigns.diffthis("~")
                end, {
                    buffer = bufnr,
                    desc = "VCS: [h]unk [D]iff against HEAD",
                })

                -- Navigation
                vim.keymap.set("n", "]c", function()
                    if vim.wo.diff then
                        vim.cmd.normal({ "]c", bang = true })
                    else
                        gitsigns.nav_hunk("next", { target = "all" })
                    end
                end, {
                    buffer = bufnr,
                    desc = "VCS: [n]ext [c]hange hunk",
                })
                vim.keymap.set("n", "[c", function()
                    if vim.wo.diff then
                        vim.cmd.normal({ "[c", bang = true })
                    else
                        gitsigns.nav_hunk("prev", { target = "all" })
                    end
                end, {
                    buffer = bufnr,
                    desc = "VCS: [p]revious [c]hange hunk",
                })
            end,
        },
    },
    { -- TODO: Consider to rewrite this plugin to adjust event when it is updating status
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

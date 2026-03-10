return {
    {
        -- Quality Tools
        "nvim-lint",
        opts = function(_, opts)
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

            return vim.tbl_deep_extend("force", opts, {
                ---@type table<string, string[]>
                linters_by_ft = {
                    gitcommit = { "gitlint" },
                },
            })
        end,
    },
    {
        "sindrets/diffview.nvim",
        config = function()
            require("diffview").setup({
                enhanced_diff_hl = true,
                show_help_hints = false,
                icons = { -- Only applies when use_icons is true.
                    folder_closed = "",
                    folder_open = "",
                },
            })
            local function toggle_diffview(cmd)
                if next(require("diffview.lib").views) == nil then
                    vim.cmd(cmd)
                else
                    vim.cmd("DiffviewClose")
                end
            end
            vim.keymap.set("n", "<localleader>tvl", function()
                toggle_diffview("DiffviewFileHistory %")
            end, { noremap = true, desc = "VCS: [t]oggle [v]cs [l]og for current file" })
            vim.keymap.set("n", "<leader>tvl", function()
                toggle_diffview("DiffviewFileHistory")
            end, { noremap = true, desc = "VCS: [t]oggle [v]cs [l]og" })
            vim.keymap.set("n", "<leader>tvs", function()
                toggle_diffview("DiffviewOpen")
            end, { noremap = true, desc = "VCS: [t]oggle [v]cs [s]tatus" })
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
}

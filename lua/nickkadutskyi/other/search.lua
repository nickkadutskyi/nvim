local utils = require("nickkadutskyi.utils")
-- Search text in file
-- Case-insensitive searching UNLESS \C or capital in search
vim.opt.ignorecase = true
vim.opt.smartcase = true
-- Incremental search
vim.opt.incsearch = true

-- Lazy.nvim modules
return {
    {
        -- Search Everywhere
        -- Faster fzf in case of a large project
        -- DEPENDENCIES: Linux or Mac, fzf or skim, OPTIONAL: fd, rg, bat, delta, chafa
        "ibhagwan/fzf-lua",
        dependencies = {
            "nickkadutskyi/jb.nvim",
        },
        config = function(_, _)
            local fzf = require("fzf-lua")
            local actions = require("fzf-lua.actions")
            fzf.setup({
                { "telescope" },
                winopts = {
                    title_pos = "center",
                    height = 25, -- window height
                    width = 85,
                    row = 0.35,
                    preview = {
                        scrollbar = false,
                        layout = "vertical",
                        vertical = "down:60%",
                    },
                    border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
                },
                actions = {
                    -- Pickers inheriting these actions:
                    --   files, git_files, git_status, grep, lsp, oldfiles, quickfix, loclist,
                    --   tags, btags, args, buffers, tabs, lines, blines
                    files = {
                        -- ["enter"] = actions.file_switch_or_edit,
                        ["enter"] = function(selected, opts)
                            -- Switch to a normal buffer if current buffer is not a normal buffer
                            local curr_bufnr = vim.api.nvim_get_current_buf()
                            local curr_winid = vim.api.nvim_get_current_win()
                            local bufnr, winid = utils.get_win_with_normal_buffer(curr_bufnr)
                            if bufnr == curr_bufnr then
                                vim.api.nvim_set_current_win(curr_winid)
                            elseif winid ~= nil then
                                vim.api.nvim_set_current_win(winid)
                            end
                            vim.schedule(function()
                                actions.file_edit_or_qf(selected, opts)
                            end)
                            -- actions.file_edit_or_qf(selected, opts)
                        end,
                        ["ctrl-i"] = actions.toggle_ignore,
                        ["ctrl-h"] = actions.toggle_hidden,
                        ["ctrl-f"] = actions.toggle_follow,
                    },
                },
                fzf_colors = true,
                fzf_opts = {
                    ["--layout"] = "reverse",
                },
                defaults = {
                    winopts = {
                        title_pos = "center",
                        height = 25, -- window height
                        width = 85,
                        row = 0.35,
                    },
                    previewer = false,
                    cwd_prompt = false,
                    prompt = "  ",
                },
                files = {
                    winopts = {
                        title = " Files ",
                        title_pos = "center",
                        height = 25, -- window height
                        width = 85,
                        row = 0.35,
                    },
                    prompt = "  ",
                    -- formatter = "path.filename_first"
                    formatter = "path.dirname_first",
                },
                buffers = {
                    winopts = { title = " Switcher ", title_pos = "center" },
                    prompt = "  ",
                },
                grep = {
                    -- Sets rg to use symlinked config file with proper colors (auto-updated on system theme change)
                    cmd = "RIPGREP_CONFIG_PATH='/Users/nick/.config/ripgrep/.ripgreprc' "
                        .. "rg --column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e",
                    winopts = {
                        title = " Find in Files ",
                        title_pos = "center",
                        height = 25, -- window height
                        width = 85,
                        row = 0.35,
                    },
                    prompt = "  ",
                    previewer = "builtin",
                    formatter = "path.dirname_first",
                },
                previewers = {
                    builtin = {
                        extensions = {
                            ["svg"] = { "viu", "-b" },
                            ["png"] = { "chafa" },
                            ["jpg"] = { "viu", "-b" },
                        },
                    },
                },
            })

            -- Go to file
            vim.keymap.set("n", "<leader>gf", function()
                -- fzf.files({ resume = true })
                fzf.files()
            end, { noremap = true, desc = "[g]o to [f]ile" })

            -- Find in path
            vim.keymap.set("n", "<leader>fp", function()
                fzf.live_grep({ resume = true })
            end, { noremap = true, desc = "[f]ind in [p]ath" })

            -- Go to buffer (Similar to Switcher in Intellij)
            vim.keymap.set("n", "<leader>gb", fzf.buffers, { noremap = true, desc = "[g]o to [b]uffer" })
            -- Go to git status
            -- vim.keymap.set("n", "<leader>ggs", fzf.git_status, { noremap = true })
            -- Go to git commits
            vim.keymap.set("n", "<leader>ggc", fzf.git_commits, { noremap = true })
            -- Go to git commits of current buffer
            vim.keymap.set("n", "<leader>ggb", fzf.git_bcommits, { noremap = true })
        end,
    },
}

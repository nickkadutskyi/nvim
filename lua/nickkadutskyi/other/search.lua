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
                "telescope", -- Sets telescope profile for look and feel
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
                    files = {
                        -- ["enter"] = actions.file_switch_or_edit,
                        ["enter"] = function(selected, opts)
                            -- vim.notify(vim.inspect(selected))
                            -- vim.notify(vim.inspect(opts))

                            local bufnr, winid = utils.get_normal_buffer(vim.api.nvim_get_current_buf())
                            if bufnr ~= nil then
                                vim.notify(vim.inspect(selected) .. " " .. vim.inspect({bufnr, winid}))
                                vim.api.nvim_set_current_win(winid)
                            end
                            vim.schedule(function()
                                actions.file_edit_or_qf(selected, opts)
                            end)
                            -- actions.file_edit_or_qf(selected, opts)
                        end,
                    },
                },
                fzf_colors = true,
                fzf_opts = {
                    ["--layout"] = "reverse",
                    ["--border"] = "top",
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
                },
                buffers = {
                    winopts = { title = " Switcher ", title_pos = "center" },
                    prompt = "  ",
                },
                grep = {
                    winopts = {
                        title = " Find in Files ",
                        title_pos = "center",
                        height = 25, -- window height
                        width = 85,
                        row = 0.35,
                    },
                    prompt = "  ",
                    previewer = "builtin",
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

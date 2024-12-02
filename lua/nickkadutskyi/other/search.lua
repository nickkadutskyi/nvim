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
        opts = {
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
        },
        config = function(_, opts)
            local fzf = require("fzf-lua")
            fzf.setup(opts)
            -- Go to file
            vim.keymap.set("n", "<leader>gf", fzf.files, { noremap = true, desc = "[g]o to [f]ile" })
            -- Find in path
            vim.keymap.set("n", "<leader>fp", fzf.live_grep, { noremap = true, desc = "[f]ind in [p]ath" })
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

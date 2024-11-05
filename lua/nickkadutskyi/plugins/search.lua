return {
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.8",
        -- or                              , branch = '0.1.x',
        dependencies = { "nvim-lua/plenary.nvim" },
    },
    {
        -- Faster fzf in case of a large project
        -- DEPENDENCIES: Linux or Mac, fzf or skim, OPTIONAL: fd, rg, bat, delta, chafa
        "ibhagwan/fzf-lua",
        opts = {
            "telescope", -- Sets telescope profile for look and feel
            winopts = {
                title_pos = "left",
                height = 30, -- window height
                width = 85,
                row = 0.75,
                preview = {
                    scrollbar = false,
                    layout = "vertical",
                    vertical = "down:60%",
                },
            },
            fzf_colors = {
                ["fg"] = { "fg", "CursorLine" },
                ["bg"] = { "bg", "Normal" },
                ["hl"] = { "fg", "Comment" },
                ["fg+"] = { "fg", "Normal" },
                ["bg+"] = { "bg", "CursorLine" },
                ["hl+"] = { "fg", "Statement" },
                ["info"] = { "fg", "PreProc" },
                ["prompt"] = { "fg", "Conditional" },
                ["pointer"] = { "fg", "Exception" },
                ["marker"] = { "fg", "Keyword" },
                ["spinner"] = { "fg", "Label" },
                ["header"] = { "fg", "Comment" },
                ["gutter"] = { "bg", "EndOfBuffer" },
            },
            fzf_opts = {
                ["--layout"] = "reverse",
            },
            defaults = {
                winopts = {
                    title_pos = "left",
                },
                previewer = false,
                cwd_prompt = false,
                prompt = "  ",
            },
            files = {
                winopts = { title = " Files ", title_pos = "left" },
                prompt = "  ",
            },
            buffers = {
                winopts = { title = " Switcher ", title_pos = "left" },
                prompt = "  ",
            },
            grep = {
                winopts = { title = " Find in Files ", title_pos = "left" },
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

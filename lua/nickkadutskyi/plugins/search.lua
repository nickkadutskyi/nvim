return {
    -- Faster fzf in case of a large project
    -- DEPENDENCIES: Linux or Mac, fzf or skim, OPTIONAL: fd, rg, bat, delta, chafa
    "ibhagwan/fzf-lua",
    opts = {
        "telescope", -- Sets telescope profile for look and feel
        winopts = {
            title_pos = "left",
            height = 0.85, -- window height
            width = 85,
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
        files = {
            winopts = {
                title = " Files ",
                title_pos = "left",
            },
            previewer = false,
            cwd_prompt = false,
            prompt = "  ",
        },
        buffers = {
            winopts = {
                title = " Files ",
                title_pos = "left",
            },
            previewer = false,
            cwd_prompt = false,
            prompt = "  ",
        },
        grep = {
            winopts = {
                title = " Find in Files ",
                title_pos = "left",
            },
            prompt = "  ",
            cwd_prompt = false,
        },
        previewers = {
            builtin = {
                extensions = {
                    ["svg"] = { "chafa" },
                    ["png"] = { "chafa", "<file>" },
                    ["jpg"] = { "chafa" },
                },
            },
        },
    },
    config = function(_, opts)
        local fzf = require("fzf-lua")
        fzf.setup(opts)
        -- Go to file
        vim.keymap.set("n", "<leader>gf", fzf.files, { noremap = true })
        -- Go to Class
        vim.keymap.set("n", "<leader>gc", function()
            fzf.lsp_live_workspace_symbols({
                regex_filter = "Class.*",
                winopts = { title = " Classes ", title_pos = "left" },
                prompt = "  ",
                previewer = false,
                cwd_only = true,
            })
        end, { noremap = true })
        -- Go to Symbol (same as class)
        vim.keymap.set("n", "<leader>gs", function()
            fzf.lsp_live_workspace_symbols({
                winopts = { title = " Project Symbols ", title_pos = "left" },
                prompt = "  ",
                previewer = false,
                cwd_only = true,
            })
        end, { noremap = true })
        vim.keymap.set("n", "<leader>gas", function()
            fzf.lsp_live_workspace_symbols({
                winopts = { title = " All Symbols ", title_pos = "left" },
                prompt = "  ",
                previewer = false,
                cwd_only = false,
            })
        end, { noremap = true })
        -- Find in path
        vim.keymap.set("n", "<leader>fp", fzf.live_grep, { noremap = true })
        -- Go to buffer (Similar to Switcher in Intellij)
        vim.keymap.set("n", "<leader>gb", fzf.buffers, { noremap = true })
        -- Go to git status
        vim.keymap.set("n", "<leader>ggs", fzf.git_status, { noremap = true })
        -- Go to git commits
        vim.keymap.set("n", "<leader>ggc", fzf.git_commits, { noremap = true })
        -- Go to git commits of current buffer
        vim.keymap.set("n", "<leader>ggb", fzf.git_bcommits, { noremap = true })
    end,
}

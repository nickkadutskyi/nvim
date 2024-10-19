return {
    -- Faster fzf in case of a large project
    -- DEPENDENCIES: Linux or Mac, fzf or skim, OPTIONAL: fd, rg, bat, delta, chafa
    "ibhagwan/fzf-lua",
    opts = {
        "telescope", -- Sets telescope profile for look and feel
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
        local nnoremap = require("nickkadutskyi.keymap").nnoremap
        local fzf = require("fzf-lua")
        fzf.setup(opts)
        -- Go to file
        nnoremap("<leader>gf", fzf.files, {})
        -- Go to Class
        nnoremap("<leader>gc", fzf.lsp_live_workspace_symbols, {})
        -- Go to Symbol (same as class)
        nnoremap("<leader>gs", fzf.lsp_live_workspace_symbols, {})
        -- Find in path
        nnoremap("<leader>fp", fzf.live_grep, {})
        -- Go to buffer (Similar to Switcher in Intellij)
        nnoremap("<leader>gb", fzf.buffers, {})
        -- Go to git status
        nnoremap("<leader>ggs", fzf.git_status, {})
        -- Go to git commits
        nnoremap("<leader>ggc", fzf.git_commits, {})
        -- Go to git commits of current buffer
        nnoremap("<leader>ggb", fzf.git_bcommits, {})
    end,
}

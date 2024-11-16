return {
    -- Treesitter for syntax highlight
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    enabled = true,
    opts = {
        ensure_installed = {
            "bash",
            "lua",
            "vim",
            "vimdoc",
            "yaml",
            "regex",
            "html",
            "c",
            "php",
            "phpdoc",
            "javascript",
            "jsdoc",
            "typescript",
            "css",
            "gitignore",
            "http",
            "sql",
            "comment",
        },
        auto_install = true, -- Automatically install missing parsers
        sync_install = false, -- Install parsers synchronously
        highlight = {
            enable = true,
            -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
            -- Set this to `true` if you depend on "syntax" being enabled (like for indentation).
            -- Using this option may slow down your editor, and you may see some duplicate highlights.
            -- Instead of true it can also be a list of languages
            additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
        incremental_selection = {
            enable = true,
            keymaps = {
                init_selection = "<A-Up>",
                node_incremental = "<A-Up>",
                scope_incremental = "<C-s>",
                node_decremental = "<A-Down>",
            },
        },
    },
    config = function(_, opts)
        require("nvim-treesitter.configs").setup(opts)
    end,
}

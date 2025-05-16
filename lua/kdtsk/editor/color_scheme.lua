-- Limits syntax highlighting columns in case of long lines
vim.opt.synmaxcol = 500
-- RGB colors
vim.opt.termguicolors = true

---@type LazySpec
return {
    {
        -- My new color scheme inspired by IntelliJ
        "nickkadutskyi/jb.nvim",
        lazy = false,
        priority = 1000,
        opts = {},
        dev = true,
        config = function()
            require("jb").setup({
                disable_hl_args = {
                    bold = false,
                    italic = false,
                },
                snacks = {
                    explorer = {
                        enabled = true,
                    },
                },
                transparent = true,
            })
            vim.cmd("colorscheme jb")
        end,
    },
    {
        -- Treesitter for syntax highlight
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        enabled = true,
        opts = {
            -- merged from:
            -- kdtsk.languages_frameworks
            ensure_installed = {
                "c",
                "comment",
                "cpp",
                "css",
                "doxygen",
                "editorconfig",
                "gitignore",
                "http",
                "markdown",
                "markdown_inline",
                "regex",
                "scss",
                "sql",
                "vim",
                "vimdoc",
                "yaml",
            },
            auto_install = true, -- Automatically install missing parsers
            sync_install = false, -- Install parsers synchronously
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },
            indent = { enable = true },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<A-Up>",
                    node_incremental = "<A-Up>",
                    scope_incremental = "<A-s>",
                    node_decremental = "<A-Down>",
                },
            },
        },
        config = function(_, opts)
            require("nvim-treesitter.configs").setup(opts)

            -- Treesitter Inspect builtin
            vim.keymap.set("n", "<leader>si", ":Inspect<CR>", {
                noremap = true,
                desc = "TS: [s]how Treesitter [i]nspection",
            })
            vim.keymap.set("n", "<leader>sti", ":InspectTree<CR>", {
                noremap = true,
                desc = "TS: [s]how Treesitter [t]ree [i]nspection",
            })
        end,
    },
}

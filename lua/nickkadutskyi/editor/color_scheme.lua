-- Limits syntax highlighting columns in case of long lines
vim.opt.synmaxcol = 500
-- RGB colors
vim.opt.termguicolors = true

return {
    {
        -- My new color scheme inspired by IntelliJ
        "nickkadutskyi/jb.nvim",
        lazy = false,
        priority = 1000,
        opts = {},
        dev = true,
        config = function()
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
            -- nickkadutskyi.languages_frameworks
            ensure_installed = {
                "bash",
                "vim",
                "vimdoc",
                "yaml",
                "regex",
                "html",
                "c",
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
    {
        -- Disables treesitter and lsp if the file matches some pattern (for minified or large files)
        "LunarVim/bigfile.nvim",
        lazy = false,
        event = { "FileReadPre", "BufReadPre", "User FileOpened" },
        opts = {
            -- features to disable
            features = {
                "lsp",
                "treesitter",
            },
            line_len_limit = 30000,
            filesize = 3,
        },
        config = function(plugin, opts)
            local uv = vim.uv or vim.loop
            require("bigfile").setup({
                pattern = function(bufnr, filesize_mib)
                    local filepath = vim.api.nvim_buf_get_name(bufnr)
                    local stat = uv.fs_stat(filepath)
                    if not stat or stat.type ~= "file" then
                        return false
                    end
                    local filesize_mib_precise = stat.size / (1024 * 1024)
                    local file_content = vim.fn.readfile(vim.api.nvim_buf_get_name(bufnr))
                    local filetype = vim.filetype.match({ buf = bufnr })
                    local message = string.format(
                        "%s %s disabled due to",
                        table.concat(opts.features, ", "),
                        #opts.features > 1 and "are" or "is"
                    )
                    -- Check filesize
                    local due_to = filesize_mib_precise <= opts.filesize and ""
                        or string.format(" file size being greater than %sMiB (%sMiB).", opts.filesize, filesize_mib)
                    -- Check length of lines
                    if due_to == "" then
                        for _, v in pairs(file_content) do
                            if #v > opts.line_len_limit then
                                due_to = string.format(
                                    " file having lines longer than %s characters (%s).",
                                    opts.line_len_limit,
                                    #v
                                )
                            end
                        end
                    end
                    if due_to ~= "" then
                        vim.notify(plugin.name .. " pattern()" .. "\n" .. message .. due_to, vim.log.levels.WARN)
                        vim.cmd("set syntax=" .. filetype)
                        return true
                    end
                    return false
                end,
                features = opts.features,
                filesize = opts.filesize,
            })
        end,
    },
}

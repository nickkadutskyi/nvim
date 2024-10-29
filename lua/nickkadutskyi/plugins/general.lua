return {
    {
        -- Improves commenting
        "numToStr/Comment.nvim",
        opts = {},
        lazy = false,
    },
    {
        -- Gutter or statusline icons, requires a Nerd Font.
        "nvim-tree/nvim-web-devicons",
        config = function()
            require("nvim-web-devicons").setup({
                override = { -- your personnal icons can go here (to override)
                    zsh = { icon = "", color = "#428850", cterm_color = "65", name = "Zsh" },
                },
                default = true, -- globally enable default icons (default to false)
                strict = true, -- globally enable "strict" selection of icons (default to false)
                override_by_filename = { -- same as `override` but for overrides by filename (requires `strict` to be true)
                    [".gitignore"] = { icon = "", color = "#f1502f", name = "Gitignore" },
                },
                override_by_extension = { -- same as `override` but for overrides by extension (requires `strict` to be true)
                    ["log"] = { icon = "", color = "#81e043", name = "Log" },
                },
            })
        end,
    },
    {
        -- Scrollbar to also show git changes not visible in current view
        "petertriho/nvim-scrollbar",
        dependencies = {
            "kevinhwang91/nvim-hlslens",
        },
        opts = {
            show = true,
            set_highlights = false,
            hide_if_all_visible = true,
            handlers = {
                diagnostic = true,
                gitsigns = true, -- Requires gitsigns
                handle = true,
                search = true, -- Requires hlslens
                cursor = false,
            },
            marks = {
                GitAdd = {
                    text = "│",
                },
                GitChange = {
                    text = "│",
                },
            },
        },
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

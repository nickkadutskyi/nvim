return {
    -- Disables treesitter and lsp if the file matches some pattern
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
                -- Check if the filepath is a regular file
                local stat = uv.fs_stat(filepath)
                if not stat or stat.type ~= "file" then
                    -- If it's not a file, skip the bigfile checks
                    return false
                end
                -- Convert bytes to MiB
                local filesize_mib_precise = stat.size / (1024 * 1024)

                local file_content = vim.fn.readfile(vim.api.nvim_buf_get_name(bufnr))
                -- local file_len = #file_content
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
                    vim.notify(message .. due_to, vim.log.levels.WARN, { title = plugin.name .. " pattern()" })
                    vim.cmd("set syntax=" .. filetype)
                    return true
                end
            end,
            features = opts.features,
        })
    end,
}

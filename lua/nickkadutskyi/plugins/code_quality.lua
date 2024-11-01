return {
    {
        "mfussenegger/nvim-lint",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            local lint = require("lint")
            lint.linters_by_ft = {
                php = {
                    "phpstan",
                    "psalm",
                    "phpcs",
                },
            }

            -- Psalm config
            -- psalm exits with 2 when there are issues in file
            lint.linters.psalm.ignore_exitcode = true
            -- adds type, link and shortcote to messages
            lint.linters.psalm.parser = function(output, bufnr)
                if output == nil then
                    return {}
                end

                local filename = vim.api.nvim_buf_get_name(bufnr)

                local messages = vim.json.decode(output)
                local diagnostics = {}

                for _, message in ipairs(messages or {}) do
                    if message.file_path == filename then
                        table.insert(diagnostics, {
                            lnum = message.line_from - 1,
                            end_lnum = message.line_to - 1,
                            col = message.column_from - 1,
                            end_col = message.column_to - 1,
                            message = message.message,
                            code = message.type .. " " .. message.link,
                            source = "psalm",
                            severity = message.severity,
                        })
                    end
                end

                return diagnostics
            end

            -- Phpstan config
            lint.linters.phpstan.parser = function(output, bufnr)
                if vim.trim(output) == "" or output == nil then
                    return {}
                end

                local file = vim.json.decode(output).files[vim.api.nvim_buf_get_name(bufnr)]

                if file == nil then
                    return {}
                end

                local diagnostics = {}

                for _, message in ipairs(file.messages or {}) do
                    local lnum = type(message.line) == "number" and (message.line - 1) or 0
                    local linecont = vim.api.nvim_buf_get_lines(bufnr, lnum, lnum + 1, false)[1] or ""
                    local col = linecont:match("()%S") or 0
                    local end_col = linecont:match(".*%S()") or 0
                    table.insert(diagnostics, {
                        lnum = lnum,
                        col = col - 1,
                        end_col = end_col - 1,
                        code = message.identifier or "", -- only works for phpstan >= 1.11
                        message = message.message,
                        source = "phpstan",
                        severity = vim.diagnostic.severity.ERROR,
                    })
                end

                return diagnostics
            end
            -- Run linters on specific events
            -- vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "InsertLeave" }, {
            -- FIXME consider when is the best time to run linters to avoid delays
            vim.api.nvim_create_autocmd({ "BufWritePost" }, {
                callback = function()
                    -- runs the linters defined in `linters_by_ft` for the current filetype
                    lint.try_lint()
                end,
            })
        end,
    },
}

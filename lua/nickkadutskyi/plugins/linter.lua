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

            -- Run linters on specific events
            vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "InsertLeave" }, {
                callback = function()
                    -- runs the linters defined in `linters_by_ft` for the current filetype
                    lint.try_lint()
                end,
            })
        end,
    },
}

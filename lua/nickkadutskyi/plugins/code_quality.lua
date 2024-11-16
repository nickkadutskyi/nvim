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
                    "php",
                    "phpmd",
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

            -- PHPCS config
            lint.linters.phpcs.parser = function(output, bufnr)
                local severities = {
                    ERROR = vim.diagnostic.severity.ERROR,
                    WARNING = vim.diagnostic.severity.WARN,
                }
                local bin = "phpcs"

                if vim.trim(output) == "" or output == nil then
                    return {}
                end

                if not vim.startswith(output, "{") then
                    vim.notify(output)
                    return {}
                end

                local decoded = vim.json.decode(output)
                local diagnostics = {}
                local messages = decoded["files"]["STDIN"]["messages"]

                for _, msg in ipairs(messages or {}) do
                    local lnum = type(msg.line) == "number" and (msg.line - 1) or 0
                    local linecont = vim.api.nvim_buf_get_lines(bufnr, lnum, lnum + 1, false)[1] or ""
                    -- highlight the whole line
                    local col = linecont:match("()%S") or 0
                    -- local col = msg.column
                    local end_col = linecont:match(".*%S()") or 0
                    table.insert(diagnostics, {
                        lnum = msg.line - 1,
                        end_lnum = msg.line - 1,
                        col = col - 1,
                        end_col = end_col - 1,
                        message = msg.message,
                        code = msg.source,
                        source = bin,
                        severity = assert(severities[msg.type], "missing mapping for severity " .. msg.type),
                    })
                end

                return diagnostics
            end

            -- PHPMD config just to change priority 3 to HINT
            lint.linters.phpmd.parser = function(output, _)
                local severities = {}
                severities[1] = vim.diagnostic.severity.ERROR
                severities[2] = vim.diagnostic.severity.WARN
                severities[3] = vim.diagnostic.severity.HINT
                severities[4] = vim.diagnostic.severity.HINT
                severities[5] = vim.diagnostic.severity.HINT

                local bin = "phpmd"

                if vim.trim(output) == "" or output == nil then
                    return {}
                end

                if not vim.startswith(output, "{") then
                    -- vim.notify(output)
                    return {}
                end

                local decoded = vim.json.decode(output)
                local diagnostics = {}
                local messages = {}

                if decoded["files"] and decoded["files"][1] and decoded["files"][1]["violations"] then
                    messages = decoded["files"][1]["violations"]
                end

                for _, msg in ipairs(messages or {}) do
                    table.insert(diagnostics, {
                        lnum = msg.beginLine - 1,
                        end_lnum = msg.endLine - 1,
                        col = 0,
                        end_col = 0,
                        message = msg.description,
                        code = msg.rule,
                        source = bin,
                        severity = assert(severities[msg.priority], "missing mapping for severity " .. msg.priority),
                    })
                end

                return diagnostics
            end

            -- Run PHP linters that require a file to be saved (no stdin)
            vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPre", "BufNewFile" }, {
                group = vim.api.nvim_create_augroup("nickkadutskyi-lint-file", { clear = true }),
                pattern = { "*.php" },
                callback = function()
                    lint.try_lint({ "phpstan", "psalm" })
                end,
            })
            -- Run PHP linters that use stdin
            vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave" }, {
                group = vim.api.nvim_create_augroup("nickkadutskyi-lint-stdin", { clear = true }),
                callback = function(e)
                    if e.file ~= "" and vim.bo.filetype == "php" then
                        lint.try_lint({ "phpcs", "php", "phpmd" })
                    end
                end,
            })
        end,
    },
}

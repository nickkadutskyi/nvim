---@class kdtsk.utils.php
local M = {}

---Find the PHP executable in the current working directory in PHP specific
---locations or globally with cache support to avoid repeated lookups.
---@param executable string The name of the PHP executable to find (e.g., "phpcs", "phpstan")
---@param cwd? string Optional current working directory to search in (defaults to vim.fn.getcwd())
---@return string|nil
function M.find_executable(executable, cwd)
    local bin, found = Utils.tools.find_executable({
        "./" .. executable .. ".phar",
        "vendor/bin/" .. executable,
        "vendor/bin/" .. executable .. ".phar",
        ".devenv/profile/bin/" .. executable,
    }, executable, cwd)
    return found and bin or nil
end

-- Overrides for nvim-lint
---@type table<string, lint.LinterLocal>
M.linters = {
    -- TODO: implement this https://docs.wpvip.com/php_codesniffer/phpcs-report/
    -- PHP Code Sniffer
    phpcs = {
        cmd = function()
            return Utils.php.find_executable("phpcs") or "phpcs"
        end,
        nix_pkg = "php84Packages.php-codesniffer",
        -- Sets col and end_col to whole row
        parser = function(output, bufnr)
            local severities = {
                ERROR = vim.diagnostic.severity.ERROR,
                WARNING = vim.diagnostic.severity.WARN,
            }

            local bin = "phpcs"
            if vim.trim(output) == "" or output == nil then
                return {}
            end

            local diagnostics = {}
            local decoded = vim.json.decode(output)
            for _, result in pairs(decoded.files) do
                for _, msg in ipairs(result.messages or {}) do
                    local lnum = type(msg.line) == "number" and (msg.line - 1) or 0
                    local linecont = vim.api.nvim_buf_get_lines(bufnr, lnum, lnum + 1, false)[1] or ""
                    local col = linecont:match("()%S") or 1
                    local end_col = linecont:match(".*%S()") or 1
                    table.insert(diagnostics, {
                        lnum = lnum,
                        col = col - 1,
                        end_col = end_col,
                        message = msg.message,
                        code = msg.source,
                        source = bin,
                        severity = assert(severities[msg.type], "missing mapping for severity " .. msg.type),
                    })
                end
            end
            return diagnostics
        end,
    },

    -- PHP Mess Detector
    phpmd = {
        cmd = function()
            return Utils.php.find_executable("phpmd") or "phpmd"
        end,
        args = {
            "-",
            "json",
            "./phpmd.xml",
        },
        nix_pkg = "php84Packages.phpmd",
        -- Adds this only to strip deprecations from output
        parser = function(output, _)
            local bin = "phpmd"
            local severities = {}
            severities[1] = vim.diagnostic.severity.ERROR
            severities[2] = vim.diagnostic.severity.WARN
            severities[3] = vim.diagnostic.severity.INFO
            severities[4] = vim.diagnostic.severity.HINT
            severities[5] = vim.diagnostic.severity.HINT

            if vim.trim(output) == "" or output == nil then
                return {}
            end

            local ok
            ok, output = Utils.linter_phpmd.strip_deprecations(output)

            if not vim.startswith(output, "{") or not ok then
                vim.notify(output)
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
        end,
    },

    -- PHPStan
    phpstan = {
        cmd = function()
            return Utils.php.find_executable("phpstan") or "phpstan"
        end,
        nix_pkg = "php84Packages.phpstan",
        -- Sets col and end_col to whole row
        parser = function(output, bufnr)
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
        end,
    },

    -- Psalm
    psalm = {
        cmd = function()
            return Utils.php.find_executable("psalm") or "psalm"
        end,
        nix_pkg = "php84Packages.psalm",
        -- Psalm exits with 2 when there are issues in file
        ignore_exitcode = true,
        -- Adds type, link and shortcote to diagnostics entries
        parser = function(output, bufnr)
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
        end,
    },
}

return M

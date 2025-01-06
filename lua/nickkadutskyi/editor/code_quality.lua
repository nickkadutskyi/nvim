return {
    { -- Code Quality
        "mfussenegger/nvim-lint",
        event = { "BufReadPre", "BufNewFile" },
        opts = { linters_by_ft = {}, linters = {} },
        config = function(_, opts)
            local lint = require("lint")
            -- Merges linters_by_ft and linters
            for linter_name, linter_opts in pairs(opts.linters) do
                if type(linter_opts) == "table" and type(lint.linters[linter_name]) == "table" then
                    lint.linters[linter_name] = vim.tbl_deep_extend("force", lint.linters[linter_name], linter_opts)
                    local prepend_args = linter_opts.prepend_args or {}
                    local append_args = linter_opts.append_args or {}
                    vim.list_extend(prepend_args, lint.linters[linter_name].args or {})
                    vim.list_extend(prepend_args, append_args)
                    lint.linters[linter_name].args = prepend_args
                else
                    lint.linters[linter_name] = linter_opts
                end
            end
            lint.linters_by_ft = opts.linters_by_ft

            local function debounce(ms, fn)
                local timer = vim.uv.new_timer()
                return function(...)
                    local argv = { ... }
                    if timer ~= nil then
                        timer:start(ms, 0, function()
                            timer:stop()
                            vim.schedule_wrap(fn)(unpack(argv))
                        end)
                    end
                end
            end

            local function try_lint(stdin)
                local linter_names = lint._resolve_linter_by_ft(vim.bo.filetype)
                linter_names = vim.list_extend({}, linter_names)
                linter_names = vim.tbl_filter(function(linter_name)
                    local support_stdin = lint.linters[linter_name].stdin
                    return stdin == true and support_stdin or not support_stdin
                end, linter_names)
                if #linter_names > 0 then
                    lint.try_lint(linter_names)
                end
            end
            -- Run linters that require a file to be saved (no stdin)
            vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPre", "BufNewFile" }, {
                group = vim.api.nvim_create_augroup("nickkadutskyi-lint-file", { clear = true }),
                callback = debounce(100, function()
                    try_lint(false)
                end),
            })
            -- Run linters that use stdin
            vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave", "BufWritePost" }, {
                group = vim.api.nvim_create_augroup("nickkadutskyi-lint-stdin", { clear = true }),
                callback = debounce(100, function()
                    try_lint(true)
                end),
            })
        end,
    },
    {
        "rshkarin/mason-nvim-lint",
        dependencies = { "mfussenegger/nvim-lint", "williamboman/mason.nvim" },
        -- ensure_installed is merged from nickkadutskyi.languages_frameworks
        opts = { automatic_installation = false },
        config = function(_, opts)
            vim.api.nvim_create_user_command("CodeLintersInstall", function()
                require("mason-nvim-lint").setup(opts)
            end, {})
        end,
    },
}

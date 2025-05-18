-- TODO: add set up process status into statusline
---@type LazySpec
return {
    {
        ---@class lint.LinterLocal : lint.Linter
        ---@field name? string
        ---@field cmd? string|fun():string
        ---@field parser? lint.Parser|lint.parse
        ---@field nix_pkg? string
        ---@field enabled? boolean
        ---@field prepend_args? string[]
        ---@field append_args? string[]

        -- Code Quality
        "mfussenegger/nvim-lint",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = { "stevearc/conform.nvim", "mason-nvim-lint" },
        opts = { linters_by_ft = {}, linters = {} },
        config = function(_, opts)
            local utils = require("kdtsk.utils")
            local lint = require("lint")
            ---@type table<string, lint.LinterLocal>
            local custom_linters = opts.linters
            ---@type table<string, string[]>
            local linters_by_ft = opts.linters_by_ft

            -- Clear previous linters
            lint.linters_by_ft = {}

            -- Gets mason-nvim-lint
            local has_mlint, mlint = pcall(require, "mason-nvim-lint")
            local lint_to_mason = has_mlint and require("mason-nvim-lint.mapping").nvimlint_to_package or {}
            local ensure_installed_via_mason = {}

            for file_type, linter_names in pairs(linters_by_ft) do
                lint.linters_by_ft[file_type] = {}

                for _, name in ipairs(linter_names) do
                    -- Adds custom linter or merges with existing one
                    local custom_linter = custom_linters[name]
                    if type(custom_linter) == "function" then
                        lint.linters[name] = custom_linter
                    elseif custom_linter ~= nil then
                        local linter = lint.linters[name]
                        if type(linter) == "function" then
                            linter = linter()
                        end
                        lint.linters[name] = vim.tbl_deep_extend("force", linter or {}, custom_linter)
                        local prepend_args = custom_linter.prepend_args or {}
                        local append_args = custom_linter.append_args or {}
                        vim.list_extend(prepend_args, lint.linters[name].args or {})
                        vim.list_extend(prepend_args, append_args)
                        lint.linters[name].args = prepend_args
                    end

                    -- Adds linter to linters_by_ft if binary exists
                    local command = (lint.linters[name] or {}).cmd
                    if (custom_linter or {}).enabled ~= false and command then
                        local via_mason, via_nix, exists, _ = utils.handle_commands({ [name] = command }, lint_to_mason)

                        -- If exists or handled via Mason then add to linters_by_ft
                        if not vim.tbl_isempty(via_mason) or not vim.tbl_isempty(exists) then
                            vim.list_extend(ensure_installed_via_mason, via_mason)
                            vim.list_extend(lint.linters_by_ft[file_type], { name })
                        end

                        -- If handled via nix then find package, update cmd and args and add to linters_by_ft
                        if not vim.tbl_isempty(via_nix) then
                            local nix_pkg = (custom_linter or {}).nix_pkg or via_nix[name]
                            utils.cmd_via_nix(nix_pkg, command, function(nix_cmd, o)
                                if o.code == 0 then
                                    lint.linters[name].cmd = table.remove(nix_cmd, 1)
                                    lint.linters[name].args = vim.list_extend(nix_cmd, lint.linters[name].args or {})
                                    vim.list_extend(lint.linters_by_ft[file_type], { name })

                                    -- Runs linter after it is configured if file type matches
                                    if string.match(vim.api.nvim_buf_get_name(0), "%." .. file_type .. "$") ~= nil then
                                        lint.try_lint({ name })
                                    end
                                end
                            end)
                        end
                    end
                end
            end

            -- Installs linters via Mason
            if has_mlint then
                mlint.setup({
                    quiet_mode = false,
                    ignore_install = {},
                    automatic_installation = false,
                    ensure_installed = ensure_installed_via_mason,
                })
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
            -- Run linters that require a file to be saved and stdin
            vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPre", "BufNewFile" }, {
                group = vim.api.nvim_create_augroup("kdtsk-lint-all", { clear = true }),
                callback = utils.debounce(100, function()
                    lint.try_lint()
                end),
            })
            -- Run linters that use stdin
            vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
                group = vim.api.nvim_create_augroup("kdtsk-lint-stdin", { clear = true }),
                callback = utils.debounce(100, function()
                    try_lint(true)
                end),
            })
        end,
    },
}

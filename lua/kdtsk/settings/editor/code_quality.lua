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
        dependencies = { "stevearc/conform.nvim" },
        opts = { linters_by_ft = {}, linters = {} },
        config = function(_, opts)
            local lint = require("lint")
            ---@type table<string, lint.LinterLocal>
            local custom_linters = opts.linters
            ---@type table<string, string[]>
            local linters_by_ft = opts.linters_by_ft

            -- Clear previous linters
            lint.linters_by_ft = {}

            -- Process enabled linters
            for file_type, linter_names in pairs(linters_by_ft) do
                lint.linters_by_ft[file_type] = {}

                for _, linter_name in ipairs(linter_names) do
                    local custom_linter = custom_linters[linter_name]

                    -- Adds customized linter definition or merges with existing one
                    if type(custom_linter) == "function" then
                        lint.linters[linter_name] = custom_linter
                    elseif custom_linter ~= nil then
                        local linter = lint.linters[linter_name]
                        if type(linter) == "function" then
                            linter = linter()
                        end
                        lint.linters[linter_name] = vim.tbl_deep_extend("force", linter or {}, custom_linter)
                        local prepend_args = custom_linter.prepend_args or {}
                        local append_args = custom_linter.append_args or {}
                        vim.list_extend(prepend_args, lint.linters[linter_name].args or {})
                        vim.list_extend(prepend_args, append_args)
                        lint.linters[linter_name].args = prepend_args
                    end

                    -- Adds linter to linters_by_ft if binary exists
                    local command = (lint.linters[linter_name] or {}).cmd
                    local run_directly, run_via_nix, binary = Utils.tools.run_command_via(command)

                    if run_directly then
                        -- If runnable directly then add to linters_by_ft
                        vim.list_extend(lint.linters_by_ft[file_type], { linter_name })
                    elseif run_via_nix then
                        -- If not runnable directly and outside of Nix shell then use Nix to run it
                        local nix_pkg = (custom_linter or {}).nix_pkg or binary
                        -- This runs async so such linter will be configured delayed
                        Utils.nix.get_cmd_via_nix(nix_pkg, command, function(nix_cmd, o)
                            if o.code == 0 then
                                -- `nix` is cmd now
                                lint.linters[linter_name].cmd = table.remove(nix_cmd, 1)
                                -- Prepend args with nix command (`run --impure ..` or `shell --impure ..`)
                                local args = vim.list_extend(nix_cmd, lint.linters[linter_name].args or {})
                                lint.linters[linter_name].args = args

                                vim.list_extend(lint.linters_by_ft[file_type], { linter_name })

                                -- Runs linter after it is configured if file type matches
                                if string.match(vim.api.nvim_buf_get_name(0), "%." .. file_type .. "$") ~= nil then
                                    lint.try_lint({ linter_name })
                                end
                            end
                        end)
                    end
                end
            end

            ---@param stdin ?boolean true—run stdin linters, false—run file linters, nil—run all
            ---@return boolean (true if attempted to run any linter)
            local function try_lint(stdin)
                if stdin == nil then
                    lint.try_lint()
                    return true
                end

                local linter_names = vim.tbl_filter(function(linter_name)
                    local support_stdin = lint.linters[linter_name].stdin
                    if stdin == true and support_stdin then
                        return true
                    elseif stdin == false and not support_stdin then
                        return true
                    end
                    return false
                end, lint._resolve_linter_by_ft(vim.bo.filetype))

                if #linter_names > 0 then
                    lint.try_lint(linter_names)
                    return true
                end

                return false
            end

            -- Run linters that require a file to be saved and stdin
            vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPre", "BufNewFile" }, {
                group = vim.api.nvim_create_augroup("kdtsk-lint-all", { clear = true }),
                callback = Utils.debounce(100, function()
                    try_lint()
                end),
            })
            -- Run linters that use stdin
            vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
                group = vim.api.nvim_create_augroup("kdtsk-lint-stdin", { clear = true }),
                callback = Utils.debounce(100, function()
                    try_lint(true)
                end),
            })

            -- Keymap
            vim.keymap.set({ "n" }, "<leader>ic", try_lint, {
                desc = "Code: [i]nspect [c]ode",
            })
        end,
    },
}

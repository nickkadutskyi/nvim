---@type LazySpec
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

            local nix_path = vim.fn.exepath("nix")
            local install_via_nix = {}
            -- Only use linters that present in the system or use `nix run`
            lint.linters_by_ft = {}
            for ft, linters in pairs(opts.linters_by_ft) do
                for _, linter_name in ipairs(linters) do
                    if vim.fn.executable(lint.linters[linter_name].cmd) == 1 then
                        lint.linters_by_ft[ft] = lint.linters_by_ft[ft] or {}
                        table.insert(lint.linters_by_ft[ft], linter_name)
                    else
                        if #nix_path ~= 0 then
                            lint.linters[linter_name].fts = lint.linters[linter_name].fts or {}
                            table.insert(lint.linters[linter_name].fts, ft)
                            table.insert(install_via_nix, linter_name)
                        end
                    end
                end
            end

            -- Installs linters via Nix (`nir run nixpkgs#<pkg> --`)
            for _, linter_name in ipairs(install_via_nix) do
                local linter_opts = lint.linters[linter_name]
                local nix_pkg = linter_opts.nix_pkg or linter_opts.cmd
                -- Checks if Nix package is available
                vim.system({ "nix", "path-info", "--json", "nixpkgs#" .. nix_pkg }, { text = true }, function(o)
                    if o.code == 0 then
                        vim.schedule(function()
                            linter_opts.cmd = "nix"
                            linter_opts.args = vim.list_extend({
                                "run",
                                "nixpkgs#" .. nix_pkg,
                                "--",
                            }, linter_opts.args or {})
                            for _, ft in ipairs(linter_opts.fts or {}) do
                                lint.linters_by_ft[ft] = lint.linters_by_ft[ft] or {}
                                vim.list_extend(lint.linters_by_ft[ft], { linter_name })
                            end
                        end)
                    end
                end)
            end

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

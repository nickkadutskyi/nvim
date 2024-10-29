return {
    {
        -- Code formatter
        "stevearc/conform.nvim",
        opts = {
            formatters_by_ft = {
                lua = { "stylua" },
                javascript = { "prettierd", "prettier" },
                css = { "prettierd", "prettier" },
                php = { "php_cs_fixer" },
                nix = { "nixfmt" },
            },
            default_format_opts = {
                lsp_format = "fallback",
                stop_after_first = true,
            },
            formatters = {
                nixfmt = {
                    args = function(_, ctx)
                        local args = {}
                        local editorconfig = vim.fs.find(".editorconfig", { path = ctx.dirname, upward = true })[1]
                        local has_editorconfig = editorconfig ~= nil

                        if has_editorconfig then
                            -- Use grep to find the line containing max_line_length
                            local result = vim.system({
                                "grep",
                                "max_line_length",
                                editorconfig,
                            }):wait()
                            if result.code == 0 then
                                local line = result.stdout
                                ---@type string
                                local len = line ~= nil and line:match("max_line_length%s*=%s*(%d+)") or "120"
                                args = { "-w", len }
                            end
                        end
                        return args
                    end,
                },
            },
        },
        config = function(_, opts)
            local conform = require("conform")
            conform.setup(opts)
            vim.keymap.set("n", "<leader>cf", conform.format, { noremap = true })
        end,
    },
    {
        -- Detect tabstop and shiftwidth automatically
        "tpope/vim-sleuth",
    },
}

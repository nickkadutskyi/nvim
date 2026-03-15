local spec = require("ide.spec.builder")
spec.add({
    "conform.nvim",
    ---@type ide.Opts.Conform
    opts = {
        formatters_by_ft = {
            xml = { { "prettierd", nil, nil, true, { lsp_format = "prefer" } } },
        },
        conform_opts = {
            formatters = {
                prettier = {
                    options = {
                        nix_pkg = "nodePackages_latest.prettier",
                    },
                    ---@param self conform.FormatterConfig
                    ---@param ctx conform.Context
                    prepend_args = function(self, ctx)
                        local args = {}
                        if ctx.filename:match("%.xml$") then
                            -- Plugin for XML have to be installed
                            vim.list_extend(args, { "--plugin=@prettier/plugin-xml" })
                        end
                        return args
                    end,
                },
            },
        },
    },
})
spec.add({
    "nvim-lspconfig",
    opts = { ---@type ide.Opts.Lsp
        clients = {
            ["lemminx"] = {
                settings = { xml = { server = { workDir = "~/.cache/lemminx" } } },
            },
        },
    },
})

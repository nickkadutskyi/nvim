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
                    prepend_args = function(_, ctx)
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
    ---@type ide.Opts.Lsp
    opts = {
        clients = {
            ["lemminx"] = {
                settings = { xml = { server = { workDir = "~/.cache/lemminx" } } },
            },
        },
    },
})

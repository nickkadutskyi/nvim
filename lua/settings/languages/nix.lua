local spec = require("ide.spec.builder")

spec.add({ "nvim-treesitter", opts = { ensure_installed = { "nix" } } })
spec.add({
    "conform.nvim",
    opts = { ---@type ide.Opts.Conform
        formatters_by_ft = {
            nix = { { "nixfmt", nil, nil, true } },
        },
        conform_opts = {
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
    },
})
spec.add({
    "nvim-lspconfig",
    opts = { ---@type ide.Opts.Lsp
        clients = {
            ["nixd"] = {
                nix_pkg = "nixd",
                settings = {
                    nixd = {
                        formatting = {
                            command = { "nixfmt" },
                        },
                    },
                },
            },
            ["nil_ls"] = {
                nix_pkg = "nil",
                capabilities = {
                    workspace = {
                        didChangeWatchedFiles = {
                            dynamicRegistration = true,
                        },
                    },
                },
                settings = {
                    ["nil"] = {
                        testSetting = 42,
                        formatting = {
                            command = { "nixfmt" },
                        },
                    },
                },
            },
        },
    },
})

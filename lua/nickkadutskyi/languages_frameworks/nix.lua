return {
    {
        "nvim-lspconfig",
        opts = {
            servers = {
                ["nixd"] = {
                    settings = {
                        nixd = {
                            formatting = {
                                command = { "nixfmt" },
                            },
                        },
                    },
                },
                ["nil_ls"] = {
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
    },
    { -- Code Style
        "stevearc/conform.nvim",
        opts = {
            formatters_by_ft = {
                nix = { "nixfmt" },
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
    },
}

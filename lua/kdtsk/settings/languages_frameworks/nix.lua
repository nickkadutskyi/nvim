---@type LazySpec
return {
    {
        "nvim-lspconfig",
        opts = {
            ---@type table<string,vim.lsp.ConfigLocal>
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
}

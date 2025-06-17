---@type LazySpec
return {
    { -- Language Servers
        "nvim-lspconfig",
        opts = {

            ---@type table<string,vim.lsp.ConfigLocal>
            servers = {
                ["lemminx"] = {
                    settings = {
                        xml = {
                            server = {
                                workDir = "~/.cache/lemminx",
                            },
                        },
                    },
                },
            },
        },
    },
    { -- Code Style
        "conform.nvim",
        opts = {
            formatters_by_ft = {
                xml = { "prettier", lsp_format = "prefer" },
            },
        },
    },
}

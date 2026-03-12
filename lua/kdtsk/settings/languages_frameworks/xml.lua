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
}

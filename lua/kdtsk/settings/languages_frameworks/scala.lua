---@type LazySpec
return {
    { -- Language Servers
        "nvim-lspconfig",
        opts = {
            ---@type table<string,vim.lsp.ConfigLocal>
            servers = {
                ["metals"] = {
                    nix_pkg = "metals",
                },
            },
        },
    },
}


---@type LazySpec
return {
    { -- Language Servers
        "nvim-lspconfig",
        opts = {
            ---@type table<string,vim.lsp.ConfigLocal>
            servers = {
                zls = {
                    -- enabled = Utils.tools.is_component_enabled("zig", "zls", Utils.tools.purpose.LSP, { "zls.json" }),
                    nix_pkg = "zls",
                },
            },
        },
    },
}

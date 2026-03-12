---@type LazySpec
return {
    { -- Language Servers
        "nvim-lspconfig",
        opts = {
            ---@type table<string,vim.lsp.ConfigLocal>
            servers = {
                pylsp = {
                    nix_pkg = "python313Packages.python-lsp-server", -- pylsp
                    enabled = Utils.tools.is_component_enabled("python", "pylsp", Utils.tools.purpose.LSP),
                },
                pyright = {
                    nix_pkg = "pyright", -- pyright-langserver
                    enabled = Utils.tools.is_component_enabled("python", "pyright", Utils.tools.purpose.LSP, {
                        "pyrightconfig.json",
                    }),
                },
            },
        },
    },
}

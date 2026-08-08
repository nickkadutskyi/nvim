local spec = require("ide.spec.builder")
local utils = require("ide.utils")

spec.add({ "nvim-treesitter", opts = { ensure_installed = { "latex", "bibtex" } } })
spec.add({
    "nvim-lspconfig",
    opts = { ---@type ide.Opts.Lsp
        clients = {
            ["texlab"] = { nix_pkg = "texlab" },
            ["ltex_plus"] = {
                enabled = {
                    nil,
                    function()
                        local bin = "ltex-ls-plus"
                        local found, bin = utils.tool.find_executable({ ".devenv/profile/bin/" .. bin }, bin)
                        return found
                    end,
                },
                nix_pkg = "ltex-ls-plus",
            },
        },
    },
})

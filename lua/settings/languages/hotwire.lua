local spec = require("ide.spec.builder")
local utils = require("ide.utils")

spec.add({
    "nvim-lspconfig",
    ---@type ide.Opts.Lsp
    opts = {
        clients = {
            ["stimulus_ls"] = {
                filetypes = { "html", "ruby", "eruby", "blade", "php", "twig", "javascript" },
                nix_pkg = false,
                bin = function()
                    return utils.tool.find_js_executable("stimulus-language-server")
                end,
            },
            ["turbo_ls"] = {
                filetypes = { "html", "ruby", "eruby", "blade", "php", "twig", "javascript" },
                nix_pkg = false,
                bin = function()
                    return utils.tool.find_js_executable("turbo-language-server")
                end,
            },
        },
    },
})

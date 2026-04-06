local spec = require("ide.spec.builder")
local utils = require("ide.utils")

spec.add({
    "nvim-lspconfig",
    opts = { ---@type ide.Opts.Lsp
        clients = {
            ["stimulus_ls"] = {
                filetypes = { "html", "ruby", "eruby", "blade", "php", "twig" },
                bin = function()
                    return utils.tool.find_js_executable("stimulus-language-server")
                end,
            },
            ["turbo-lsp"] = {
                filetypes = { "html", "ruby", "eruby", "blade", "php", "twig" },
                bin = function()
                    return utils.tool.find_js_executable("turbo-language-server")
                end,
            },
        },
    },
})

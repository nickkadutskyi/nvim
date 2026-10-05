local spec = require("ide.spec.builder")
local utils = require("ide.utils")

--- OPTIONS --------------------------------------------------------------------

-- utils.run.now_if_arg_or_deferred(function()
-- NOTE: Disabled it to use via blink.cmp for awhile
-- Used to let copilot-language-server to provide inline completions
-- vim.lsp.inline_completion.enable()
-- end)

spec.add({
    "nvim-lspconfig",
    opts = { ---@type ide.Opts.Lsp
        clients = {
            ["copilot"] = {
                settings = {
                    telemetry = {
                        telemetryLevel = "off",
                    },
                },
            },
        },
    },
})

--- PLUGINS --------------------------------------------------------------------

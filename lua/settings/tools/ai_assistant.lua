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

spec.add({
    "copilot.lua",
    opts = {
        suggestion = {
            auto_trigger = true,
            keymap = {
                accept_word = "<M-S-l>",
                accept_line = false,
            },
        },
    },
})

vim.api.nvim_create_autocmd("User", {
    pattern = "BlinkCmpMenuOpen",
    callback = function()
        vim.b.copilot_suggestion_hidden = true
    end,
})

vim.api.nvim_create_autocmd("User", {
    pattern = "BlinkCmpMenuClose",
    callback = function()
        vim.b.copilot_suggestion_hidden = false
    end,
})

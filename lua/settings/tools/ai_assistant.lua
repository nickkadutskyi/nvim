local spec = require("ide.spec.builder")
local utils = require("ide.utils")

--- OPTIONS --------------------------------------------------------------------

-- utils.run.now_if_arg_or_deferred(function()
-- NOTE: Disabled it to use via blink.cmp for awhile
-- Used to let copilot-language-server to provide inline completions
-- vim.lsp.inline_completion.enable()
-- end)

--- PLUGINS --------------------------------------------------------------------

-- Let copilot.lua own attachment; native LSP can attach first and skip its keymaps.
spec.add({
    "copilot.lua",
    opts = {
        server_opts_overrides = {
            settings = {
                telemetry = {
                    telemetryLevel = "off",
                },
            },
        },
        suggestion = {
            auto_trigger = true,
            keymap = {
                accept = "<Tab>",
                accept_word = "<A-Tab>",
                accept_line = "<S-Tab>",
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

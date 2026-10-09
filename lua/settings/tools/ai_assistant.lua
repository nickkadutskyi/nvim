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
    "copilot-lsp",
    before = function()
        vim.g.copilot_nes_debounce = 500
        vim.lsp.enable("copilot_ls")
        vim.keymap.set("n", "<esc>", function()
            if not require("copilot-lsp.nes").clear() then
                return ""
            end
            return "<Cmd>nohlsearch<CR><Esc>"
        end, { expr = true, desc = "Clear Copilot suggestion or fallback" })
        vim.keymap.set("n", "<tab>", function()
            local bufnr = vim.api.nvim_get_current_buf()
            local state = vim.b[bufnr].nes_state
            if state then
                -- Try to jump to the start of the suggestion edit.
                -- If not at the start, then walk to the start of the edit.
                -- If already at the start, then apply the pending suggestion and jump to the end of the edit.
                local _ = require("copilot-lsp.nes").walk_cursor_start_edit()
                    or (
                        require("copilot-lsp.nes").apply_pending_nes()
                        and require("copilot-lsp.nes").walk_cursor_end_edit()
                    )
                return nil
            else
                -- Resolving the terminal's inability to distinguish between `TAB` and `<C-i>` in normal mode
                return "<C-i>"
            end
        end, { desc = "Accept Copilot NES suggestion", expr = true })
    end,
})

spec.add({
    "copilot.lua",
    opts = {
        suggestion = {
            auto_trigger = true,
        },
        nes = {
            enabled = true,
            keymap = {
                accept_and_goto = "<leader>p",
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

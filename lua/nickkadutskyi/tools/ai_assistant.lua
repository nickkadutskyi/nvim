local utils = require("nickkadutskyi.utils")

return {
    { -- AI Suggestions
        "github/copilot.vim",
        enabled = true,
        init = function()
            utils.add_cwd_to_copilot_workspace_folders()
        end,
    },
    -- {
    --     "zbirenbaum/copilot.lua",
    --     cmd = "Copilot",
    --     enabled = false,
    --     event = "InsertEnter",
    --     config = function()
    --         require("copilot").setup({
    --             suggestion = {
    --                 enabled = true,
    --                 auto_trigger = true,
    --                 hide_during_completion = true,
    --                 debounce = 75,
    --                 keymap = {
    --                     accept = "<Tab>",
    --                     accept_word = "<A-Tab>",
    --                     accept_line = "<S-Tab>",
    --                     next = (vim.fn.has("mac") and "‘" or "<A-]>"),
    --                     prev = (vim.fn.has("mac") and "“" or "<A-[>"),
    --                     dismiss = "<C-]>",
    --                 },
    --             },
    --         })
    --     end,
    -- },
    { -- AI Chat
        "CopilotC-Nvim/CopilotChat.nvim",
        branch = "canary",
        dependencies = {
            { "github/copilot.vim" }, -- or github/copilot.lua
            { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
        },
        build = "make tiktoken", -- Only on MacOS or Linux
        opts = {
            -- See Configuration section for options
        },
        -- See Commands section for default commands if you want to lazy load on them
    },
}

return {
    { -- AI Suggestions -- Keep this config to eaisly switch between implementations (copilot.vim or copilot.lua)
        "github/copilot.vim",
        enabled = false,
        dependencies = { "folke/which-key.nvim" },
        init = function()
            require("nickkadutskyi.utils").add_cwd_to_copilot_workspace_folders()
            vim.g.copilot_filetypes = { ["copilot-chat"] = false }
        end,
        config = function()
            -- Keymap
            vim.keymap.set("i", "<A-]>", "<Plug>(copilot-next)", { desc = "AI: Next suggestion (copilot.vim)" })
            vim.keymap.set("i", "<A-[>", "<Plug>(copilot-previous)", { desc = "AI: Previous suggestion (copilot.vim)" })
            vim.keymap.set("i", "<A-Tab>", "<Plug>(copilot-accept-word)", {
                desc = "AI: Accept word suggestion (copilot.vim)",
            })
            vim.keymap.set("i", "<S-Tab>", "<Plug>(copilot-accept-line)", {
                desc = "AI: Accept line suggestion (copilot.vim)",
            })
            -- macOS specific aliases
            vim.keymap.set("i", "‘", "<A-]>", { remap = true, desc = "AI: Next suggestion (macOS alias)" })
            vim.keymap.set("i", "“", "<A-[>", { remap = true, desc = "AI: Previous suggestion (macOS alias)" })
            -- Documents built-in keymap
            require("which-key").add({
                { "<Tab>", desc = "AI: Accept suggestion (copilot.vim)", mode = "i" },
                { "<C-]>", desc = "AI: Dismiss suggestion (copilot.vim)", mode = "i" },
            })
        end,
    },
    { -- AI Suggestions -- Use this in cmp-nvim completion dialog
        "zbirenbaum/copilot.lua",
        dependencies = { "folke/which-key.nvim" },
        cmd = "Copilot",
        enabled = true,
        event = "InsertEnter",
        config = function()
            require("copilot").setup({
                panel = { enabled = false }, -- disabled to use only in completion dialog
                suggestion = {
                    enabled = false, -- disabled to use only in completion dialog
                    auto_trigger = true,
                    keymap = {
                        accept = "<Tab>",
                        accept_word = false,
                        accept_line = false,
                        next = false,
                        prev = false,
                        dismiss = "<C-]>",
                    },
                },
                filetypes = { ["copilot-chat"] = false },
            })

            if require("copilot.config").get("suggestion").enabled then
                -- Keymap only if suggestion is enabled
                local suggestion = require("copilot.suggestion")
                vim.keymap.set("i", "<A-]>", suggestion.next, { desc = "AI: Next suggestion (copilot.lua)" })
                vim.keymap.set("i", "<A-[>", suggestion.prev, { desc = "AI: Previous suggestion (copilot.lua)" })
                vim.keymap.set("i", "<A-Tab>", suggestion.accept_word, {
                    desc = "AI: Accept word suggestion (copilot.lua)",
                })
                vim.keymap.set("i", "<S-Tab>", suggestion.accept_line, {
                    desc = "AI: Accept line suggestion (copilot.lua)",
                })
                -- macOS specific aliases
                vim.keymap.set("i", "‘", "<A-]>", { remap = true, desc = "AI: Next suggestion (macOS alias)" })
                vim.keymap.set("i", "“", "<A-[>", { remap = true, desc = "AI: Previous suggestion (macOS alias)" })
                -- Documents built-in keymap
                require("which-key").add({
                    { "<Tab>", desc = "AI: Accept suggestion (copilot.lua)", mode = "i" },
                    { "<C-]>", desc = "AI: Dismiss suggestion (copilot.lua)", mode = "i" },
                })
            end
        end,
    },
    { -- AI Suggestions from copilot.lua in cmp-nvim completion dialog source provider
        "zbirenbaum/copilot-cmp",
        config = true,
    },
    { -- AI Suggestions from Supermaven (works way faster than GitHub Copilot)
        "supermaven-inc/supermaven-nvim",
        enabled = true,
        config = function()
            require("supermaven-nvim").setup({
                keymaps = {
                    accept_suggestion = "<Tab>",
                    clear_suggestion = "<C-]>",
                    accept_word = nil,
                },
                disable_inline_completion = false,
                ignore_filetypes = { "copilot-chat" }, -- for CopilotC-Nvim/CopilotChat.nvim plugin
            })

            -- Keymap
            vim.keymap.set("i", "<A-Tab>", require("supermaven-nvim.completion_preview").on_accept_suggestion_word, {
                silent = true,
                desc = "AI: Accept word suggestion (Supermaven)",
            })
            -- Documents built-in keymap
            require("which-key").add({
                { "<Tab>", desc = "AI: Accept suggestion (Supermaven)", mode = "i" },
                { "<C-]>", desc = "AI: Dismiss suggestion (Supermaven)", mode = "i" },
            })

            -- Auto Commands
            -- Assigns existing SupermavenSuggestion highlight group to ghost text
            vim.api.nvim_create_autocmd({ "ColorScheme" }, {
                group = vim.api.nvim_create_augroup("nickkadutskyi-supermaven-colorscheme", { clear = true }),
                callback = function()
                    if vim.fn.hlexists("SupermavenSuggestion") == 1 then
                        -- Uses interna api
                        local smp = require("supermaven-nvim.completion_preview")
                        smp.suggestion_group = "SupermavenSuggestion"
                    end
                end,
            })
        end,
    },
    { -- AI Chat -- Well integrate with Copilot Chat
        "CopilotC-Nvim/CopilotChat.nvim",
        branch = "canary",
        dependencies = {
            { "github/copilot.vim" }, -- or github/copilot.lua
            { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
        },
        build = "make tiktoken", -- Only on MacOS or Linux
        opts = {
            -- See Configuration section for options
            model = "claude-3.5-sonnet",
        },
        -- See Commands section for default commands if you want to lazy load on them
        config = function(_, opts)
            require("CopilotChat").setup(opts)

            -- Keymap

            vim.keymap.set("n", "<leader>aa", "<cmd>CopilotChat<cr>", {
                desc = "AI Assist: [a]ctivate [a]i assistant",
            })

            -- Integrations

            -- Registers copilot-chat filetype for markdown rendering
            require("render-markdown").setup({
                file_types = { "markdown", "copilot-chat" },
            })
        end,
    },
}

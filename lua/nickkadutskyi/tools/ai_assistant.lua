---@type LazySpec
return {
    { -- AI Suggestions -- Keep this config to eaisly switch between implementations (copilot.vim or copilot.lua)
        "github/copilot.vim",
        enabled = false, -- using copilot.lua so that copilot-lualine works
        dependencies = { "folke/which-key.nvim" },
        init = function()
            require("nickkadutskyi.utils").add_cwd_to_copilot_workspace_folders()
            vim.g.copilot_filetypes = { ["copilot-chat"] = false }
            vim.g.copilot_settings = { selectedCompletionModel = "gpt-4o-copilot" }
            vim.g.copilot_integration_id = "vscode-chat"
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
            -- Documents built-in keymap
            require("which-key").add({
                { "<Tab>", desc = "AI: Accept suggestion (copilot.vim)", mode = "i" },
                { "<C-]>", desc = "AI: Dismiss suggestion (copilot.vim)", mode = "i" },
            })
        end,
    },
    { -- AI Suggestions -- Using this in cmp-nvim completion dialog
        "zbirenbaum/copilot.lua",
        dependencies = { "folke/which-key.nvim" },
        cmd = "Copilot",
        enabled = true,
        event = "InsertEnter",
        config = function()
            require("copilot").setup({
                panel = { enabled = false }, -- disabled to use only in completion dialog
                suggestion = {
                    enabled = true, -- disabled to use only in completion dialog
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
                copilot_model = "gpt-4o-copilot",
            })

            -- if require("copilot.config").get("suggestion").enabled then
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
            -- Documents built-in keymap
            require("which-key").add({
                { "<Tab>", desc = "AI: Accept suggestion (copilot.lua)", mode = "i" },
                { "<C-]>", desc = "AI: Dismiss suggestion (copilot.lua)", mode = "i" },
            })
            -- end
        end,
    },
    { -- AI Suggestions from copilot.lua in cmp-nvim completion dialog source provider
        "zbirenbaum/copilot-cmp",
        config = true,
    },
    {
        "yetone/avante.nvim",
        enabled = true,
        event = "VeryLazy",
        lazy = false,
        -- Set this to "*" to always pull the latest release version, or set
        -- it to false to update to the latest code changes.
        version = false,
        -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
        build = "make",
        -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
        dependencies = {
            "stevearc/dressing.nvim",
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",

            --- The below dependencies are optional,
            "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
            "ibhagwan/fzf-lua", -- for file_selector provider fzf
            "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
            "zbirenbaum/copilot.lua", -- for providers='copilot'
        },

        config = function()
            require("avante_lib").load()
            require("avante").setup({
                provider = "copilot",
                copilot = {
                    model = "claude-3.7-sonnet",
                },
                vendors = {
                    ["copilot/o3-mini"] = {
                        __inherited_from = "copilot",
                        model = "o3-mini",
                    },
                    ["copilot/claude-3.5-sonnet"] = {
                        __inherited_from = "copilot",
                        model = "claude-3.5-sonnet",
                    },
                },
                mappings = {
                    ask = "<localleader>aa",
                    edit = "<localleader>ea",
                    focus = "<leader>afa",
                    toggle = {
                        default = "<leader>aa",
                    },
                    files = {
                        -- Add current buffer to selected files
                        add_current = "<localleader>afa",
                    },
                },
                windows = {
                    width = 40,
                    input = {
                        prefix = "> ",
                    },
                },
            })

            -- Keymap
            local wk = require("which-key")
            wk.add({
                { "<leader>aa", desc = "AI: [a]ctivate [a]i assistant" },
                { "<leader>afa", desc = "AI: [a]ctivate [f]ocus on [a]i assistant" },
                { "<localleader>aa", desc = "AI: [a]ctivate [a]i assistant to ask", mode = { "n", "v" } },
                { "<localleader>ea", desc = "AI: [e]dit with [a]i assistant", mode = { "v" } },
                { "<localleader>afa", desc = "AI: [a]dd current [f]ile to [a]i assistant chat" },
            })
        end,
    },
}

---@type LazySpec
return {
    { -- AI Inline Suggestions for the very next tokens
        "zbirenbaum/copilot.lua",
        dependencies = { "folke/which-key.nvim" },
        cmd = "Copilot",
        event = "InsertEnter",
        lazy = true,
        cond = function()
            local allowed_paths = {
                "~/Developer/.*",
                "~/%.config/nvim.*",
                "~/%.config/nixos-config.*",
            }

            local cwd = vim.fn.getcwd():gsub("^" .. vim.fn.expand("~"), "~")

            -- Check if cwd matches any of the allowed paths
            for _, pattern in ipairs(allowed_paths) do
                if cwd:match("^" .. pattern .. "$") then
                    return true
                end
            end

            return false
        end,
        opts = {
            panel = { enabled = false },
            suggestion = {
                enabled = true,
                auto_trigger = true,
                keymap = {
                    accept = "<Tab>",
                    accept_word = "<A-Tab>",
                    accept_line = "<S-Tab>",
                    next = "<A-]>",
                    prev = "<A-[>",
                    dismiss = "<C-]>",
                },
            },
            filetypes = { ["copilot-chat"] = false },
            copilot_model = "gpt-4o-copilot",
            server_opts_overrides = {
                settings = {
                    telemetry = {
                        telemetryLevel = "off",
                    },
                },
            },
        },
        config = function(_, opts)
            require("copilot").setup(opts)

            -- Documents built-in keymap
            require("which-key").add({
                { "<Tab>", desc = "AI: Accept suggestion", mode = "i" },
                { "<A-Tab>", desc = "AI: Accept word suggestion", mode = "i" },
                { "<S-Tab>", desc = "AI: Accept line suggestion", mode = "i" },
                { "<A-]>", desc = "AI: Next suggestion", mode = "i" },
                { "<A-[>", desc = "AI: Previous suggestion", mode = "i" },
                { "<C-]>", desc = "AI: Dismiss suggestion", mode = "i" },
            })
            -- end
        end,
    },
    { -- AI Chat/Code Editor
        "yetone/avante.nvim",
        event = "VeryLazy",
        -- Set this to "*" to always pull the latest release version, or set
        -- it to false to update to the latest code changes.
        version = false,
        -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
        build = "make",
        lazy = true,
        dependencies = {
            "stevearc/dressing.nvim",
            "MunifTanjim/nui.nvim",
            "nvim-lua/plenary.nvim",
        },
        opts = {
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
                edit = {
                    border = "rounded",
                },
            },
        },
        config = function(_, opts)
            require("avante").setup(opts)

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

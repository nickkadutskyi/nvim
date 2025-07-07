---@type LazySpec
return {
    { -- AI Suggestions
        "github/copilot.vim",
        dependencies = { "folke/which-key.nvim" },
        cond = function()
            return Utils.is_path_in_paths(vim.fn.getcwd(), {
                "~/Documents",
                "~/.config/nvim",
                "~/.config/nixos-config",
            })
        end,
        init = function()
            vim.g.copilot_settings = { selectedCompletionModel = "gpt-4o-copilot" }
            vim.g.copilot_integration_id = "vscode-chat"
            vim.g.copilot_lsp_settings = {
                telemetry = {
                    telemetryLevel = "off",
                },
            }
        end,
        config = function()
            -- Keymap
            vim.keymap.set("i", "<A-]>", "<Plug>(copilot-next)", { desc = "AI: Next suggestion" })
            vim.keymap.set("i", "<A-[>", "<Plug>(copilot-previous)", { desc = "AI: Previous suggestion" })
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
            provider = "copilot/claude-sonnet-4",
            providers = {
                ["copilot/o3-mini"] = {
                    __inherited_from = "copilot",
                    model = "o3-mini",
                },
                ["copilot/claude-3.5-sonnet"] = {
                    __inherited_from = "copilot",
                    model = "claude-3.5-sonnet",
                },
                ["copilot/claude-sonnet-4"] = {
                    __inherited_from = "copilot",
                    model = "claude-sonnet-4",
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

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
}

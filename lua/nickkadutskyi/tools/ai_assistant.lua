---@type LazySpec
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
    { -- AI Suggestions from Supermaven (works way faster than GitHub Copilot implemented in copilot.lua or copilot.vim)
        "supermaven-inc/supermaven-nvim",
        enabled = false,
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
        enabled = true,
        branch = "main",
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

            -- vim.keymap.set("n", "<leader>aa", "<cmd>CopilotChat<cr>", {
            --     desc = "AI: [a]ctivate [a]i assistant",
            -- })

            -- Integrations

            -- Registers copilot-chat filetype for markdown rendering
            -- require("render-markdown").setup({
            --     file_types = { "markdown", "copilot-chat" },
            -- })
        end,
    },
    {
        "olimorris/codecompanion.nvim",
        enabled = false,
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
        config = function()
            require("codecompanion").setup({
                adapters = {
                    copilot = function()
                        return require("codecompanion.adapters").extend("copilot", {
                            schema = {
                                model = {
                                    default = "claude-3.5-sonnet",
                                    -- default = "o3-mini",
                                },
                                max_tokens = {
                                    default = 65536,
                                },
                            },
                        })
                    end,
                },
                strategies = {
                    --NOTE: Change the adapter as required
                    chat = {
                        adapter = "copilot",
                        -- roles = {
                        --     -- I'm using hardcoded roles because there is another issue for llm-dynamic role for custom adapter.
                        --     llm = "Assistant",
                        --     user = "User",
                        -- },
                    },
                    inline = { adapter = "copilot" },
                },
            })

            -- Keymap
            vim.keymap.set("n", "<leader>aa", "<cmd>CodeCompanionChat<cr>", {
                desc = "AI: [a]ctivate [a]i assistant",
            })
        end,
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
                    endpoint = "https://api.githubcopilot.com/",
                    -- model = "o1",
                    model = "o3-mini",
                    -- claude can use with avante
                    -- model = "claude-3.5-sonnet",
                    proxy = nil, -- [protocol://]host[:port] Use this proxy
                    allow_insecure = false, -- Allow insecure server connections
                    timeout = 30000, -- Timeout in milliseconds
                    temperature = 0,
                    -- max_tokens = 8192,
                },
                mappings = {
                    ask = "<localleader>aa",
                    edit = "<localleader>ea",
                    -- refresh = "<leader>ar",
                    focus = "<leader>afa",
                    toggle = {
                        default = "<leader>aa",
                        -- debug = "<leader>ad",
                        -- hint = "<leader>ah",
                        -- suggestion = "<leader>as",
                        -- repomap = "<leader>aR",
                    },
                    files = {
                        -- Add current buffer to selected files
                        add_current = "<localleader>afa",
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
                { "<localleader>afa", desc = "AI: [a]dd current [f]ile to [a]i assitant chat" },
            })
            -- vim.keymap.set("n", "<leader>aa", "<cmd>AvanteChat<cr>", {
            --     desc = "AI: [a]ctivate [a]i assistant",
            -- })
        end,
    },
}

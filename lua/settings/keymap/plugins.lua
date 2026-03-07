local spec_builder = require("ide.spec.builder")

--- OPTIONS --------------------------------------------------------------------

--- MAPPINGS -------------------------------------------------------------------

require("ide.utils").run.now_if_arg_or_deferred(function()
    --- Lazy.nvim for managing plugins
    vim.keymap.set("n", "<leader>ol", function()
        require("lazy").show()
    end, { silent = true, desc = "Plugins: [o]pen [l]azy.nvim manager" })
end)

spec_builder.add({
    "which-key.nvim",
    keys = {
        {
            lhs = "<leader>?n",
            rhs = function()
                require("which-key").show({ mode = "n", global = true })
            end,
            desc = "WK: Global keymap for normal mode",
        },
        {
            lhs = "<leader>?i",
            rhs = function()
                require("which-key").show({ mode = "i", global = true })
            end,
            desc = "WK: Global keymaps for insert mode",
        },
        {
            lhs = "<localleader>?n",
            rhs = function()
                require("which-key").show({ mode = "n", global = false })
            end,
            desc = "WK: Buffer keymap for normal mode",
        },
        {
            lhs = "<localleader>?i",
            rhs = function()
                require("which-key").show({ mode = "i", global = false })
            end,
            desc = "WK: Buffer keymaps for insert mode",
        },
    },
})

--- PLUGINS --------------------------------------------------------------------

spec_builder.add({
    "which-key.nvim",
    ---@type wk.Opts
    opts = {
        -- Provides Keymap Groups:
        -- [Leader|LocalLeader|None] > [Action] > [Modifier|None] > [Object]
        spec = {
            { "<leader>", group = "Leader" },
            { -- Global Context
                "<leader>",
                group = "Leader",

                { "<leader>/", group = "[/]search", icon = { icon = "󰮗", hl = "WhichKeyValue" } },
                { "<leader>?", group = "[?]help", icon = { icon = "󰘥", hl = "WhichKeyValue" } },
                { "<leader>a", group = "[a]dd", icon = { icon = "", hl = "WhichKeyValue" } },
                { "<leader>f", group = "[f]ind", icon = { icon = "", hl = "WhichKeyValue" } },
                { "<leader>g", group = "[g]o to", icon = { icon = "", hl = "WhichKeyValue" } },
                { "<leader>i", group = "[i]nspect", icon = { icon = "", hl = "WhichKeyValue" } },
                { "<leader>o", group = "[o]pen", icon = { icon = "", hl = "WhichKeyValue" } },
                { "<leader>r", group = "[r]eformat", icon = { icon = "", hl = "WhichKeyValue" } },
                {
                    "<leader>s",
                    group = "[s]how",
                    icon = { icon = "", hl = "WhichKeyValue" },

                    { "<leader>sr", group = "[r]ecent", icon = { icon = "", hl = "WhichKeyValue" } },
                },
                {
                    "<leader>t",
                    group = "[t]oggle",
                    icon = { icon = "", hl = "WhichKeyValue" },

                    { "<leader>tv", group = "[v]ersion control", icon = { icon = "󰘬", hl = "WhichKeyValue" } },
                },
            },
            { -- Local Context
                "<localleader>",
                group = "LocalLeader",

                { "<localleader>?", group = "[?]help", icon = { icon = "󰘥", hl = "WhichKeyValue" } },
                { "<localleader>a", group = "[a]dd", icon = { icon = "", hl = "WhichKeyValue" } },
                {
                    "<localleader>h",
                    group = "VCS: [h]unk",
                    mode = { "v", "n" },
                    icon = { icon = "󰘬", hl = "WhichKeyValue" },
                },
                { "<localleader>o", group = "[o]pen", icon = { icon = "", hl = "WhichKeyValue" } },
                {
                    "<localleader>t",
                    group = "[t]oggle",
                    icon = { icon = "", hl = "WhichKeyValue" },

                    { "<localleader>tv", group = "[v]ersion control", icon = { icon = "󰘬", hl = "WhichKeyValue" } },
                },
            },
            { "]", group = "[n]ext" },
            { "[", group = "[p]rev" },

            -- Treesitter
            { "<A-Up>", desc = "TS: Init Incremental Selection | Increment Node" },
            { "<A-s>", desc = "TS: Increment Scope" },
            { "<A-Down>", desc = "TS: Decrement Node" },
        },
        delay = 1500,
        icons = {
            rules = {
                { pattern = "^plugins:.*", icon = "", color = "grey" },
                { pattern = "^vcs:.*", icon = "", color = "grey" },
                { pattern = "%[v%]ersion control", icon = "", color = "grey" },
                { pattern = "^terminal:.*", icon = "", color = "grey" },
                { pattern = "^run:.*", icon = "󰑮", color = "grey" },
                { pattern = "^ai:.*", icon = "󱙺", color = "grey" },
                { pattern = "^project:.*", icon = "", color = "grey" },
            },
            mappings = vim.g.nerd_font_is_present,
            keys = vim.g.nerd_font_is_present and {} or {
                Up = "<Up> ",
                Down = "<Down> ",
                Left = "<Left> ",
                Right = "<Right> ",
                C = "<C-…> ",
                M = "<M-…> ",
                D = "<D-…> ",
                S = "<S-…> ",
                CR = "<CR> ",
                Esc = "<Esc> ",
                ScrollWheelDown = "<ScrollWheelDown> ",
                ScrollWheelUp = "<ScrollWheelUp> ",
                NL = "<NL> ",
                BS = "<BS> ",
                Space = "<Space> ",
                Tab = "<Tab> ",
                F1 = "<F1>",
                F2 = "<F2>",
                F3 = "<F3>",
                F4 = "<F4>",
                F5 = "<F5>",
                F6 = "<F6>",
                F7 = "<F7>",
                F8 = "<F8>",
                F9 = "<F9>",
                F10 = "<F10>",
                F11 = "<F11>",
                F12 = "<F12>",
            },
        },
        sort = { "desc", "group", "alphanum", "local", "order", "mod" },
        keys = {
            scroll_down = "<c-n>", -- binding to scroll down inside the popup
            scroll_up = "<c-p>", -- binding to scroll up inside the popup
        },
        plugins = {
            marks = false, -- shows a list of your marks on ' and `
            registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
            -- the presets plugin, adds help for a bunch of default keybindings in Neovim
            -- No actual key bindings are created
            presets = {
                operators = true, -- adds help for operators like d, y, ...
                motions = true, -- adds help for motions
                text_objects = true, -- help for text objects triggered after entering an operator
                windows = true, -- default bindings on <c-w>
                nav = true, -- misc bindings to work with windows
                z = true, -- bindings for folds, spelling and others prefixed with z
                g = true, -- bindings for prefixed with g
            },
        },
    },
})

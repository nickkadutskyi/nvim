---@type LazySpec
return {
    {
        -- Keymap search and documentation
        "folke/which-key.nvim",
        event = "VimEnter",
        enabled = true,
        ---@type wk.Opts
        opts = {
            spec = {
                -- Provides Keymap Groups: [Leader|LocalLeader|None] > [Action] > [Modifier|None] > [Object]

                -- Global Context
                {
                    "<Leader>",
                    group = "Leader",

                    -- /Search
                    { "<leader>/", group = "[/]search" },
                    -- ?Help
                    { "<leader>?", group = "[?]help" },
                    -- Activate
                    {
                        "<leader>a",
                        group = "[a]ctivate",

                        -- Focus
                        { "<leader>af", group = "[f]ocus" },
                        -- VCS
                        { "<leader>av", group = "[v]ersion control" },
                    },
                    -- Choose
                    { "<leader>c", group = "[c]hoose" },
                    -- Expose
                    { "<leader>e", group = "[e]xpose" },
                    -- Find
                    { "<leader>f", group = "[f]ind" },
                    -- Go to
                    { "<leader>g", group = "[g]o to" },
                    -- Reformat
                    { "<leader>r", group = "[r]eformat" },
                    -- Show
                    {
                        "<leader>s",
                        group = "[s]how",
                        icon = { icon = "", hl = "WhichKeyValue" },

                        -- Recent
                        { "<leader>sr", group = "[r]ecent" },
                    },
                    -- Toggle
                    { "<leader>t", group = "[t]oggle" },
                },
                -- Local Context
                {
                    "<LocalLeader>",
                    group = "LocalLeader",

                    -- Activate
                    {
                        "<localleader>a",
                        group = "[a]ctivate",
                        mode = { "v", "n" },

                        -- ?Help
                        { "<localleader>?", group = "[?]help" },
                        -- VCS
                        { "<localleader>av", group = "[v]ersion control" },
                    },
                    -- Edit
                    { "<localleader>e", group = "[e]dit", mode = { "v", "n" } },
                    -- Toggle
                    { "<localleader>t", group = "[t]oggle" },
                },
                -- Next
                { "]", group = "[n]ext" },
                -- Previous
                { "[", group = "[p]rev" },
                -- TODO moves to a file related to Treesitter
                -- Treesitter
                { "<A-Up>", desc = "TS: Init Incremental Selection | Increment Node" },
                { "<A-s>", desc = "TS: Increment Scope" },
                { "<A-Down>", desc = "TS: Decrement Node" },
            },
            delay = 200,
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
        config = function(_, opts)
            local wk = require("which-key")
            wk.setup(opts)

            -- Keymap
            vim.keymap.set("n", "<leader>?n", function()
                wk.show({ mode = "n", global = true })
            end, { silent = true, desc = "Global keymap for normal mode" })
            vim.keymap.set("n", "<leader>?i", function()
                wk.show({ mode = "i", global = true })
            end, { silent = true, desc = "Global keymaps for insert mode" })
            vim.keymap.set("n", "<localleader>?n", function()
                wk.show({ mode = "n", global = false })
            end, { silent = true, desc = "Buffer keymap for normal mode" })
            vim.keymap.set("n", "<localleader>?i", function()
                wk.show({ mode = "i", global = false })
            end, { silent = true, desc = "Buffer keymaps for insert mode" })
        end,
    },
}

local spec_builder = require("ide.spec.builder")
local pack = require("ide.pack")

-- 0 Commit (Compose a commit, stage/unstage hunks/files)
-- 1 Project (Project view/Explorer)
spec_builder.add({
    "folke/trouble.nvim",
    keys = {
        {
            desc = "Problems: [t]oggle [p]roblem tool window",
            lhs = { "<localleader>tp" },
            rhs = function()
                require("trouble").open("document_diagnostics")
            end,
        },
        {
            desc = "Problems: [t]oggle [p]roblem tool window",
            lhs = { "<leader>tp" },
            rhs = function()
                require("trouble").open("workspace_diagnostics")
            end,
        },
    },
})
-- 2 Bookmarks
spec_builder.add({
    "ThePrimeagen/harpoon",
    keys = {
        {
            lhs = { "<C-e>", "<leader>ob" },
            rhs = function()
                local harpoon = require("harpoon")
                local opts = {
                    title = " Bookmarks ",
                    title_pos = "center",
                    ui_max_width = 75,
                }
                if pack.is_loaded("jb.nvim") then
                    opts.border = require("jb.borders").borders.dialog.default_box_header_shadowed
                end
                harpoon.ui:toggle_quick_menu(harpoon:list(), opts)
            end,
            desc = "Bookmarks: [o]pen [b]ookmarks",
        },
    },
})

-- 5 Debug (DAP)
-- 6 Problems (Displays detected problems)
-- 7 Structure (Overview of a class or struct etc.)
spec_builder.add({
    "folke/trouble.nvim",
    keys = {
        {
            desc = "Structure: [a]ctivate [s]tructure",
            lhs = { "<localleader>os" },
            rhs = function()
                require("trouble").open("symbols")
            end,
        },
    },
})
-- 8 Services (DB, Docker, Podman etc.)
-- 9 Git (Git Log)

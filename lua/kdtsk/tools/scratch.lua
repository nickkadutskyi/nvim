return {
    {
        "LintaoAmons/scratch.nvim",
        event = "VeryLazy",
        dependencies = { "ibhagwan/fzf-lua", "ahmedkhalf/project.nvim" },
        config = function()
            vim.keymap.set({ "n", "v", "i" }, "<A-C><A-A>", "<cmd>Scratch<cr>", {
                desc = "Scratch: Create new scratch file",
            })
            vim.keymap.set({ "n", "v", "i" }, "<A-S-N>", "<cmd>Scratch<cr>", {
                desc = "Scratch: Create new scratch file",
            })

            vim.keymap.set({ "n", "v", "i" }, "<A-C><A-S>", "<cmd>ScratchOpen<cr>", {
                desc = "Scratch: Show list of scratch files",
            })
            vim.keymap.set({ "n", "v", "i" }, "<A-S-O>", "<cmd>ScratchOpen<cr>", {
                desc = "Scratch: Show list of scratch files",
            })

            local cwd = vim.fn.getcwd()
            local project_name = vim.fs.basename(cwd)
            local project_parent = vim.fs.basename(vim.fs.dirname(cwd))
            local parent_parent = vim.fs.basename(vim.fs.dirname(vim.fn.fnamemodify(cwd, ":h")))
            local subdir = parent_parent .. "-" .. project_parent .. "-" .. project_name

            require("scratch").setup({
                scratch_file_dir = vim.fn.stdpath("cache") .. "/scratches/" .. subdir,
                filetypes = {
                    "txt",
                    "json",
                    "sh",
                    "php",
                    "js",
                    "md",
                    "html",
                },
                hooks = {},
                filetype_details = {
                    json = {
                        content = { "{", "", "}" },
                        cursor = {
                            location = { 2, 1 },
                            insert_mode = true,
                        },
                    },
                },
                window_cmd = "edit", -- 'vsplit' | 'split' | 'edit' | 'tabedit' | 'rightbelow vsplit'
                use_telescope = false,
                file_picker = "fzflua",
                localKeys = {},
            })
        end,
    },
}

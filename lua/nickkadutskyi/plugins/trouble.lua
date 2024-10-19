return {
    "folke/trouble.nvim",
    opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
    },
    config = function(_, opts)
        local nnoremap = require("nickkadutskyi.keymap").nnoremap
        local trouble = require("trouble")
        trouble.setup(opts)
        -- Diagnostics Trouble  plugin
        -- Open Problems window
        -- nnoremap("<leader>xx", ":Trouble diagnostics toggle<CR>")
        -- Quick Fix
        -- nnoremap("<leader>xq", ":TroubleToggle quickfix<CR>")

        -- same toggle behavior as in Intellij
        local toggle_problems = function()
            local buf_name = vim.api.nvim_buf_get_name(0)
            if buf_name ~= "" then
                trouble.open({ mode = "diagnostics", focus = true })
            else
                trouble.close({ mode = "diagnostics", focus = true })
            end
        end
        nnoremap("<C-6>", toggle_problems)
        nnoremap("<leader>xx", toggle_problems)

        -- TODO check the rest of the mappings
        nnoremap("<leader>xw", function()
            trouble.toggle("workspace_diagnostics")
        end)
        nnoremap("<leader>xd", function()
            trouble.toggle("document_diagnostics")
        end)
        nnoremap("<leader>xq", function()
            trouble.toggle("quickfix")
        end)
        nnoremap("<leader>xl", function()
            trouble.toggle("loclist")
        end)
        nnoremap("gR", function()
            trouble.toggle("lsp_references")
        end)
        nnoremap("gd", function()
            trouble.toggle("lsp_definitions")
        end)
        nnoremap("gi", function()
            trouble.toggle("lsp_implementations")
        end)
    end,
}

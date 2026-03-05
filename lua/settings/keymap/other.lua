--- MAPPINGS -------------------------------------------------------------------

require("ide.utils").run.now_if_args(function()
    -- Treesitter Inspect builtin
    vim.keymap.set("n", "<leader>ip", "<cmd>Inspect<CR>", {
        desc = "Other:TS: [i]spect Treesitter [p]osition",
    })
    vim.keymap.set("n", "<leader>it", "<cmd>InspectTree<CR>", {
        desc = "Other:TS: [i]spect Treesitter [t]ree",
    })
end)

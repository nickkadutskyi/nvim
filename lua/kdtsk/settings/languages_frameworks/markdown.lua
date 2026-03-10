---@type LazySpec[]
return {
    {
        "MeanderingProgrammer/render-markdown.nvim",
        -- cmd = { "RenderMarkdown" },
        ---@module 'render-markdown'
        ---@type render.md.UserConfig
        opts = {
            anti_conceal = {
                enabled = false,
            },
            heading = {
                sign = false,
                position = "inline",
                icons = { "", "", "", "", "", "" },
                border = true,
            },
        },
        keys = {
            {
                "<leader>tm",
                desc = "[t]oggle [m]arkdown",
                mode = { "n" },
            },
        },
        config = function(_, opts)
            require("render-markdown").setup(opts)
            vim.api.nvim_set_hl(0, "RenderMarkdownH1", { fg = "Red", bold = true })

            vim.keymap.set({ "n" }, "<leader>tm", "<cmd>RenderMarkdown toggle<cr>", {
                desc = "[t]oggle [m]arkdown",
            })
        end,
    },
}

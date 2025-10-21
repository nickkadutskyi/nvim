---@type LazySpec[]
return {
    {
        "MeanderingProgrammer/render-markdown.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" }, -- if you prefer nvim-web-devicons
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
                "<leader>amd",
                desc = "Toggle [a]ctivate [m]ark[d]own",
                mode = { "n" },
            },
        },
        config = function(_, opts)
            require("render-markdown").setup(opts)
            vim.api.nvim_set_hl(0, "RenderMarkdownH1", { fg = "Red", bold = true })

            vim.keymap.set({ "n" }, "<leader>amd", "<cmd>RenderMarkdown toggle<cr>", {
                desc = "Toggle [a]ctivate [m]ark[d]own",
            })
        end,
    },
}

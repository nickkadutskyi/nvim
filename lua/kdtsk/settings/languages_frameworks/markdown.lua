return {
    {
        "MeanderingProgrammer/render-markdown.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" }, -- if you prefer nvim-web-devicons
        cmd = { "RenderMarkdown" },
        ---@module 'render-markdown'
        ---@type render.md.UserConfig
        opts = {},
        config = function(_, opts)
            require("render-markdown").setup(opts)

            vim.keymap.set({ "n" }, "<leader>md", "<cmd>RenderMarkdown toggle<cr>", {
                noremap = true,
                silent = true,
                desc = "Toggle [m]ark[d]own Render",
            })
        end,
    },
}

local spec_builder = require("ide.spec.builder")

spec_builder.add({
    {
        "lazydev.nvim",
        opts = {
            library = {
                -- Load luvit types when the `vim.uv` word is found
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                -- { path = "lazy.nvim", words = { "Lazy" } },
                -- { path = "inc-rename.nvim", words = { "inc_rename" } },
                -- { path = "nvim-gitstatus", words = { "GitStatus" } },
                -- { path = "auto-dark-mode.nvim", words = { "AutoDarkMode" } },
                -- { path = "jb.icons", words = { "jb.icons" } },
                -- { path = "snacks.nvim", words = { "Snacks" } },
            },
        },
    },
})

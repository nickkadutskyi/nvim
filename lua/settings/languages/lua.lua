local spec = require("ide.spec.builder")

spec.add({ "nvim-treesitter", opts = { ensure_installed = { "lua", "luadoc", "luap" } } })

spec.add({
    "mfussenegger/nvim-lint",
    ---@type ide.Opts.Lint
    opts = {
        linters_by_ft = {
            lua = {
                { "selene", { "selene.toml" } },
                { "luachecke", { ".luacheckrc" } },
            },
        },
        linters = {
            selene = { nix_pkg = "selene" },
            luacheck = { nix_pkg = "luajitPackages.luacheck" },
        },
    },
})

spec.add({
    "conform.nvim",
    opts = {
        formatters_by_ft = {
            lua = { { "stylua", nil, nil, true, { timeout_ms = 2000 } } },
        },
    },
})

spec.add({
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
})

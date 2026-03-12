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

local spec = require("ide.spec.builder")

spec.add({ "nvim-treesitter", opts = { ensure_installed = { "blade" } } })
spec.add({
    "conform.nvim",
    ---@type ide.Opts.Conform
    opts = {
        formatters_by_ft = {
            blade = {
                { "_", nil, nil, true, { async = true, timeout_ms = 1500 } },
                { "blade-formatter", { ".bladeformatterrc.json", ".bladeformatterrc" } },
                {
                    "prettierd",
                    { ".prettierrc", ".prettierrc.json", ".prettierrc.js", ".prettierrc.yaml", ".prettierrc.yml" },
                },
                { "prettier" },
            },
        },
        conform_opts = {
            formatters = {
                ["blade-formatter"] = { nix_pkg = "blade-formatter" },
            },
        },
    },
})

local spec = require("ide.spec.builder")

spec.add({ "nvim-treesitter", opts = { ensure_installed = { "zig" } } })

spec.add({
    "nvim-lint",
    ---@type ide.Opts.Lint
    opts = {
        linters_by_ft = {
            zig = {
                { "zig", { "build.zig" } },
                { "zlint" },
            },
        },
        linters = { zlint = { nix_pkg = "zig-zlint" } },
    },
})
spec.add({
    "conform.nvim",
    ---@type ide.Opts.Conform
    opts = { formatters_by_ft = { zig = { { "zigfmt", nil, nil, true, { lsp_format = "fallback" } } } } },
})
spec.add({
    "nvim-lspconfig",
    opts = { ---@type ide.Opts.Lsp
        clients = {
            zls = {
                -- enalbed = { { "zls.json" } },
                nix_pkg = "zls",
            },
        },
    },
})

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

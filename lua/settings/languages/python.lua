local spec = require("ide.spec.builder")

spec.add({ "nvim-treesitter", opts = { ensure_installed = { "python" } } })

spec.add({
    "nvim-lint",
    ---@type ide.Opts.Lint
    opts = {
        linters_by_ft = {
            python = {
                { "ruff", { "ruff.toml", ".ruff.toml" } },
                { "flake8", { ".flake8" } },
                { "pylint" },
            },
        },
        linters = {
            flake8 = { nix_pkg = "python314Packages.flake8" },
        },
    },
})

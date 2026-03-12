local spec = require("ide.spec.builder")

spec.add({ "nvim-treesitter", opts = { ensure_installed = { "yaml" } } })

spec.add({
    "nvim-lint",
    ---@type ide.Opts.Lint
    opts = {
        linters_by_ft = {
            yaml = { { "yamllint", { ".yamllint", ".yamllint.yaml", ".yamllint.yml" } } },
        },
    },
})

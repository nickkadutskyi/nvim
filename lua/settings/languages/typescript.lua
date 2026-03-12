local spec = require("ide.spec.builder")

spec.add({ "nvim-treesitter", opts = { ensure_installed = { "typescript", "tsx" } } })

spec.add({
    "nvim-lint",
    ---@type ide.Opts.Lint
    opts = {
        linters_by_ft = {
            typescript = {
                { "eslint_d", { "eslint.config.ts", "eslint.config.mts", "eslint.config.cts" } },
                { "eslint", { "eslint.config.js", "eslint.config.mjs", "eslint.config.cjs" } },
            },
        },
    },
})

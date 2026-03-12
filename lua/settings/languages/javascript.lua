local spec = require("ide.spec.builder")

spec.add({ "nvim-treesitter", opts = { ensure_installed = { "javascript", "jsdoc", "jsx" } } })
spec.add({
    "mfussenegger/nvim-lint",
    ---@type ide.Opts.Lint
    opts = { linters_by_ft = { javascript = { { "eslint_d", nil, nil, true } } } },
})

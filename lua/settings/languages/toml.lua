local spec = require("ide.spec.builder")

spec.add({ "nvim-treesitter", opts = { ensure_installed = { "toml" } } })
spec.add({
    "conform.nvim",
    ---@type ide.Opts.Conform
    opts = { formatters_by_ft = { toml = { { "taplo", nil, nil, true } } } },
})

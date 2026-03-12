local spec = require("ide.spec.builder")

spec.add({ "nvim-treesitter", opts = { ensure_installed = { "rust" } } })

spec.add({ "nvim-lint", opts = { linters_by_ft = { rust = { { "clippy", nil, nil, true } } } } })

spec.add({
    "conform.nvim",
    ---@type ide.Opts.Conform
    opts = { formatters_by_ft = { rust = { { "rustfmt", nil, nil, true, { lsp_format = "fallback" } } } } },
})

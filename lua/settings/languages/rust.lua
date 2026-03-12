local spec = require("ide.spec.builder")

spec.add({ "nvim-treesitter", opts = { ensure_installed = { "rust" } } })

spec.add({ "nvim-lint", opts = { linters_by_ft = { rust = { { "clippy", nil, nil, true } } } } })


local spec = require("ide.spec.builder")

spec.add({ "nvim-treesitter", opts = { ensure_installed = { "ruby" } } })
spec.add({
    "conform.nvim",
    ---@type ide.Opts.Conform
    opts = {
        formatters_by_ft = { ruby = { { "standardrb", nil, nil, true, { lsp_format = "fallback" } } } },
        conform_opts = {
            formatters = {
                standardrb = { options = { nix_pkg = "rubyPackages.standard" } },
            },
        },
    },
})

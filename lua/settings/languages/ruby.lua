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
spec.add({
    "nvim-lspconfig",
    opts = { ---@type ide.Opts.Lsp
        clients = {
            ["rubocop"] = {
                enabled = { { "rubocop", ".rubocop.yml" } },
            },
            ["ruby_ls"] = {
                enabled = { { ".index.yml", "ruby-lsp", "ruby-lsp.gemspec" } },
            },
            ["solargraph"] = {
                enabled = { { "Gemfile", "solargraph.yml" } },
            },
            ["standardrb"] = { -- as linter
                enabled = { { "standardrb" }, nil, false },
                nix_pkg = "rubyPackages.standard",
            },
        },
    },
})

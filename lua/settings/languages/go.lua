local spec_builder = require("ide.spec.builder")

spec_builder.add({
    "nvim-treesitter",
    opts = { ---@type ide.Opts.Treesitter
        ensure_installed = { "go", "gotmpl" },
        syntax_map = { ["gotexttmpl"] = "gotmpl", ["gohtmltmpl"] = "gotmpl" },
    },
})

local spec_builder = require("ide.spec.builder")

spec_builder.add({ -- Color Scheme
    "nvim-treesitter",
    opts = { ---@type ide.Opts.Treesitter
        ensure_installed = { "scala" },
    },
})

local spec_builder = require("ide.spec.builder")

spec_builder.add({
    "nvim-treesitter",
    opts_extend = { "ensure_installed" },
    ---@type ide.Opts.Treesitter
    opts = {
        ensure_installed = { "vim", "vimdoc" },
        syntax_map = {
            ["tiltfile"] = "starlark",
            ["gotexttmpl"] = "gotmpl",
            ["gohtmltmpl"] = "gotmpl",
        },
        auto_install = true, -- Automatically install missing parsers
        sync_install = false, -- Install parsers synchronously
        highlight = { enable = true },
        indent = { enable = true },
    },
    after = function(_, opts)
        local utils = require("ide.utils")

        -- Ensure specified parsers are installed.
        utils.treesitter.ensure_installed(opts)

        utils.treesitter.create_auto_start_autocmd(opts)
    end,
})

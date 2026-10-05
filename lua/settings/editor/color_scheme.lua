local spec = require("ide.spec.builder")

--- OPTIONS --------------------------------------------------------------------

-- Limits syntax highlighting columns in case of long lines
vim.opt.synmaxcol = 500
-- RGB colors
vim.opt.termguicolors = true

--- PLUGINS --------------------------------------------------------------------

spec.add({
    "jb.nvim",
    after = function()
        require("jb").setup({
            transparent = false,
            integrations = { ghostty = true, fff = true },
        })

        -- Enable color scheme
        vim.cmd("colorscheme jb")
    end,
})

spec.add({
    "auto-dark-mode.nvim",
    opts = {
        set_dark_mode = function()
            vim.api.nvim_set_option_value("background", "dark", {})
        end,
        set_light_mode = function()
            vim.api.nvim_set_option_value("background", "light", {})
        end,
        update_interval = 3000,
        fallback = "light",
    },
})

spec.add({
    "nvim-treesitter",
    ---@type ide.Opts.Treesitter
    opts = {
        -- Previous ensure installed
        ensure_installed = { "comment", "vim", "vimdoc", "editorconfig", "sql", "regex", "http" },
        syntax_map = { ["tiltfile"] = "starlark" },
        auto_install = true, -- Automatically install missing parsers
        sync_install = false, -- Install parsers synchronously
        highlight = { enable = true },
        indent = { enable = true },
    },
})

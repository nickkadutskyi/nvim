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
            integrations = { ghostty = true },
            enforce_float_style = {
                {
                    style = { border = require("jb.borders").borders.dialog.default_box_header_shadowed },
                    condition = function(_, config)
                        if type(config.title) ~= "string" then
                            return false
                        end
                        return config.title == " Plugins " or config.title:find("99") ~= nil
                    end,
                },
                {
                    style = {
                        border = require("jb.borders").borders.dialog.default_box_split_top_no_footer_shadowed,
                    },
                    condition = function(bufnr, _)
                        local ok, fff = pcall(require, "fff.picker_ui.picker_ui_state")
                        if ok and fff ~= nil then
                            return bufnr == fff.state.input_buf
                        end
                        return false
                    end,
                },
                {
                    style = {
                        border = require("jb.borders").borders.dialog.default_box_split_middle_shadowed_no_footer,
                    },
                    condition = function(bufnr, _)
                        local ok, fff = pcall(require, "fff.picker_ui.picker_ui_state")
                        if ok and fff ~= nil then
                            return bufnr == fff.state.list_buf
                        end
                        return false
                    end,
                },
                {
                    style = {
                        border = require("jb.borders").borders.dialog.default_box_split_bottom_shadowed_header,
                    },
                    condition = function(bufnr, _)
                        local ok, fff = pcall(require, "fff.picker_ui.picker_ui_state")
                        if ok and fff ~= nil then
                            return bufnr == fff.state.preview_buf
                        end
                        return false
                    end,
                },
            },
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

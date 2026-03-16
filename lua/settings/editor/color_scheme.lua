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
            transparent = true,
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
                        local ok, fff = pcall(require, "fff.picker_ui")
                        if not ok or not fff.state then
                            return false
                        end
                        return bufnr == fff.state.input_buf
                    end,
                },
                {
                    style = {
                        border = require("jb.borders").borders.dialog.default_box_split_middle_shadowed_no_footer,
                    },
                    condition = function(bufnr, _)
                        local ok, fff = pcall(require, "fff.picker_ui")
                        if not ok or not fff.state then
                            return false
                        end
                        return bufnr == fff.state.list_buf
                    end,
                },
                {
                    style = {
                        border = require("jb.borders").borders.dialog.default_box_split_bottom_shadowed_header,
                    },
                    condition = function(bufnr, _)
                        local ok, fff = pcall(require, "fff.picker_ui")
                        if not ok or not fff.state then
                            return false
                        end
                        return bufnr == fff.state.preview_buf
                    end,
                    after = function(winid, _, _)
                        vim.schedule(function()
                            vim.api.nvim_set_option_value(
                                "winhl",
                                "Normal:Normal,IncSearch:FzfLuaSearch,FloatTitle:DialogFloatBorderTop",
                                { win = winid }
                            )
                        end)
                    end,
                },
            },
        })

        -- Enable color scheme
        vim.cmd("colorscheme jb")
    end,
})

spec.add({
    "nvim-treesitter",
    ---@type ide.Opts.Treesitter
    opts = {
        -- Previous ensure installed
        ensure_installed = { "comment", "vim", "vimdoc", "editorconfig", "tmux", "sql", "regex", "http" },
        syntax_map = { ["tiltfile"] = "starlark" },
        auto_install = true, -- Automatically install missing parsers
        sync_install = false, -- Install parsers synchronously
        highlight = { enable = true },
        indent = { enable = true },
    },
})

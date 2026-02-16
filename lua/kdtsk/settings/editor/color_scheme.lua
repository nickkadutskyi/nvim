-- Limits syntax highlighting columns in case of long lines
vim.opt.synmaxcol = 500
-- RGB colors
vim.opt.termguicolors = true

---@type LazySpec
return {
    {
        "nickkadutskyi/jb.nvim",
        lazy = false,
        priority = 1000,
        opts = {},
        dev = true,
        config = function()
            require("jb").setup({
                disable_hl_args = {
                    bold = false,
                    italic = false,
                },
                snacks = {
                    explorer = {
                        enabled = true,
                    },
                },
                transparent = true,
                enforce_float_style = {
                    {
                        style = { border = require("jb.borders").borders.dialog.default_box_header_shadowed },
                        condition = function(_, _, config)
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
                        condition = function(bufnr, _, _)
                            local ok, fff = pcall(require, "fff.picker_ui")
                            return not ok or not fff.state and false or bufnr == fff.state.input_buf
                        end,
                    },
                    {
                        style = {
                            border = require("jb.borders").borders.dialog.default_box_split_middle_shadowed_no_footer,
                        },
                        condition = function(bufnr, _, _)
                            local ok, fff = pcall(require, "fff.picker_ui")
                            return not ok or not fff.state and false or bufnr == fff.state.list_buf
                        end,
                    },
                    {
                        style = {
                            border = require("jb.borders").borders.dialog.default_box_split_bottom_shadowed_header,
                        },
                        condition = function(bufnr, _, _)
                            local ok, fff = pcall(require, "fff.picker_ui")
                            return not ok or not fff.state and false or bufnr == fff.state.preview_buf
                        end,
                        after = function(winid, _, _)
                            vim.schedule(function()
                                vim.api.nvim_set_option_value("winhl", "Normal:Normal,IncSearch:FzfLuaSearch,FloatTitle:DialogFloatBorderTop", { win = winid })
                            end)
                        end,
                    },
                },
            })
            vim.cmd("colorscheme jb")
        end,
    },
    -- Treesitter for syntax highlight
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        branch = "main",
        build = ":TSUpdate",
        enabled = true,
        opts = {
            -- merged from:
            -- kdtsk.languages_frameworks
            ensure_installed = {
                "c",
                "comment",
                "cpp",
                "css",
                "doxygen",
                "editorconfig",
                "gitignore",
                "http",
                "markdown",
                "markdown_inline",
                "regex",
                "scss",
                "sql",
                "vim",
                "vimdoc",
                "yaml",
            },
            auto_install = true, -- Automatically install missing parsers
            sync_install = false, -- Install parsers synchronously
            highlight = {
                enable = true,
            },
            indent = { enable = true },
        },
        config = function(_, opts)
            local ts = require("nvim-treesitter")
            local ts_config = require("nvim-treesitter.config")

            local ensure_installed = opts.ensure_installed
            local already_installed = ts_config.get_installed("parsers")
            local parsers_to_install = vim.iter(ensure_installed)
                :filter(function(parser)
                    return not vim.tbl_contains(already_installed, parser)
                end)
                :totable()

            if #parsers_to_install > 0 then
                ts.install(parsers_to_install)
            end

            -- filetype overrides
            local syntax_map = {
                ["tiltfile"] = "starlark",
                ["gotexttmpl"] = "gotmpl",
                ["gohtmltmpl"] = "gotmpl",
            }

            local function ts_start(bufnr, parser_name)
                if opts.highlight.enable then
                    vim.treesitter.start(bufnr, parser_name)
                    -- Use regex based syntax-highlighting as fallback as some plugins might need it
                    -- vim.bo[bufnr].syntax = "ON"
                end
                -- Use treesitter for folds
                vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
                vim.wo.foldtext = "v:lua.vim.treesitter.foldtext()"

                if opts.indent.enable then
                    -- Use treesitter for indentation
                    -- vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end
            end

            ts.setup({
                -- Directory to install parsers and queries to
                install_dir = vim.fn.stdpath("data") .. "/site",
            })

            -- Auto-install and start parsers for any buffer
            vim.api.nvim_create_autocmd({ "FileType" }, {
                desc = "Enable Treesitter",
                callback = function(event)
                    local bufnr = event.buf
                    local filetype = event.match

                    -- Skip if no filetype
                    if filetype == "" then
                        return
                    end
                    -- Get parser name based on filetype
                    local lang = vim.tbl_get(syntax_map, filetype)
                    if lang == nil then
                        lang = filetype
                    else
                        vim.notify("Using language override " .. lang)
                    end
                    local parser_name = vim.treesitter.language.get_lang(lang)
                    if not parser_name then
                        vim.notify(
                            vim.inspect("No treesitter parser found for filetype: " .. lang),
                            vim.log.levels.WARN
                        )
                        return
                    end

                    -- Try to get existing parser
                    if not vim.tbl_contains(ts_config.get_available(), parser_name) then
                        return
                    end

                    -- Check if parser is already installed
                    if not vim.tbl_contains(already_installed, parser_name) then
                        -- If not installed, install parser asynchronously and start treesitter
                        if opts.auto_install == true then
                            vim.notify("Installing parser for " .. parser_name, vim.log.levels.INFO)
                            if opts.sync_install == true then
                                ts.install({ parser_name })
                                vim.defer_fn(function()
                                    ts_start(bufnr, parser_name)
                                end, 5000)
                            else
                                -- ts.install({ parser_name })
                                ts.install({ parser_name }):await(function()
                                    ts_start(bufnr, parser_name)
                                end)
                            end
                        end
                        return
                    end

                    -- Start treesitter for this buffer
                    ts_start(bufnr, parser_name)
                end,
            })

            -- Treesitter Inspect builtin
            vim.keymap.set("n", "<leader>si", ":Inspect<CR>", {
                noremap = true,
                desc = "TS: [s]how Treesitter [i]nspection",
            })
            vim.keymap.set("n", "<leader>sti", ":InspectTree<CR>", {
                noremap = true,
                desc = "TS: [s]how Treesitter [t]ree [i]nspection",
            })
        end,
    },
}

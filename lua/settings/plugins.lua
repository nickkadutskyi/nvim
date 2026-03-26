local spec = require("ide.spec.builder")
local utils = require("ide.utils")
local g = utils.str.prepend_fn("https://github.com/")
local c = utils.str.prepend_fn("https://codeberg.org/")

--- Define all plugins with their src here. Feature files patch via name only.
spec.add({
    --- Gutter or statusline icons, Requires a Nerd Font.
    {
        src = g("nvim-tree/nvim-web-devicons"),
        data = {
            -- We load it as early as possible to be synchronious with plugins
            -- that might use it and might trigger setup before it's loaded,
            -- which would prevent them from applying the icon overrides
            event = "IdeDeferred",
            after = function(_, opts)
                --- Depends on jb.nvim for icon overrides
                utils.run.on_load("jb.nvim", function()
                    local devicons = require("nvim-web-devicons")
                    local icons = require("jb.icons")

                    opts.override_by_filename = icons.files.by_filename
                    opts.override_by_extension = icons.files.by_extension

                    devicons.setup(opts)
                    devicons.set_icon(icons.by_variant(vim.o.background))

                    -- Set icons every time the background option changes
                    utils.autocmd.create("OptionSet", {
                        group = "settings.nvim-web-devicons.sync-icons-with-bg",
                        pattern = "background",
                        callback = function()
                            utils.run.later(function()
                                devicons.set_icon(icons.by_variant(vim.o.background))
                            end)
                        end,
                    })
                end)
            end,
        },
    },
    --- A library of lua functions used by lots of plugins
    --- Required by: harpoon
    { src = g("nvim-lua/plenary.nvim"), data = { event = "IdeDeferred" } },
    --- A notification manager with a nice UI
    {
        src = g("rcarriga/nvim-notify"),
        version = "ab98fecfe",
        data = {
            -- deferred = false,
            event = "IdeDeferred",
            after = function(_, opts)
                require("notify").setup(opts)
                vim.notify_orig = vim.notify
                vim.notify = require("notify")
                local s = { "ERROR", "WANR", "INFO", "INFO", "DEBUG" }
                vim.lsp.handlers["window/showMessage"] = function(_, method, params)
                    local client = vim.lsp.get_client_by_id(params.client_id) or {}
                    local level = vim.log.levels[s[method.type]]
                    vim.notify(method.message, level, { title = "LSP: " .. (client.name or "Unknown") })
                end
            end,
        },
    },
    --- My color scheme that recreates IntelliJeJ's look and feel in Neovim
    {
        src = g("nickkadutskyi/jb.nvim"),
        data = { dev = true, deferred = false },
    },
    --- Treesitter for syntax highlighting, folding, etc.
    --- Requires: tree-sitter, tar, curl, c compiler
    {
        src = g("nvim-treesitter/nvim-treesitter"),
        data = {
            event = { "BufReadPre", "BufNewFile" },
            opts_extend = { "ensure_installed" },
            build = function()
                vim.cmd("TSUpdate")
            end,
            ---@param opts ide.Opts.Treesitter
            after = function(_, opts)
                local ide_ts = require("ide.treesitter")
                ide_ts.ensure_installed(opts.ensure_installed)
                ide_ts.create_auto_start_autocmd(opts)
                ide_ts.setup_custom_parsers(opts.custom_parsers)
            end,
        },
    },
    --- Provides a popup with possible keymaps of the command you started typing
    {
        src = g("folke/which-key.nvim"),
        data = {
            event = "IdeDeferred",
            after = function(_, opts)
                require("which-key").setup(opts)
            end,
        },
    },
    --- Compatibility layer for using nvim-cmp sources on blink.cmp
    --- Required by: 99 (when using blink as the completion source)
    {
        src = g("saghen/blink.compat"),
        data = {
            event = "IdeDeferred",
            after = function()
                require("blink.compat").setup({})
            end,
        },
    },
    --- AI Assistant for code generation, refactoring, etc.
    {
        src = g("ThePrimeagen/99"),
        data = {
            event = "IdeDeferred",
            ---@param opts _99.Options
            after = function(_, opts)
                local _99 = require("99")
                opts.logger = {
                    level = _99.DEBUG,
                    path = "/tmp/" .. vim.fs.basename(vim.uv.cwd()) .. ".99.debug",
                    print_on_error = true,
                }
                _99.setup(opts)
            end,
        },
    },
    --- LSP Progress lualine componenet
    --- Required by: lualine.nvim
    { src = g("arkav/lualine-lsp-progress"), data = { event = "IdeDeferred" } },
    --- Statusline configurator
    --- Requires: lualine-lsp-progress
    {
        src = g("nvim-lualine/lualine.nvim"),
        data = {
            event = "IdeDeferred",
            after = function(_, opts)
                -- Running it later to ensure that all components are registered
                -- because some may need to use lualine_require before lualine is setup
                utils.run.later(function()
                    require("lualine").setup(opts)
                end)
            end,
        },
    },
    --- Bookmarks manager;
    --- Loaded: on IdeDeffered because lualine-harpoon.nvim requires it to be loaded first
    --- Requires: plenary.nvim
    --- Required by: lualine-harpoon.nvim
    { src = g("ThePrimeagen/harpoon"), version = "harpoon2", data = { event = "IdeDeferred" } }, -- `after` in lua/settings/advanced/main.lua
    --- Displays your current Harpoon mark as [x/y] in your Lualine.
    --- Requires: lualine.nvim, harpoon
    {
        src = c("kristoferssolo/lualine-harpoon.nvim"),
        data = {
            event = "IdeDeferred",
            after = function(_, opts)
                require("lualine-harpoon").setup(opts)
            end,
        },
    },
    --- Status bar controller in the top right corner
    {
        src = g("b0o/incline.nvim"),
        data = {
            event = "IdeDeferred",
            after = function(_, opts)
                require("incline").setup(opts)
            end,
        },
    },
    --- Visual guides
    {
        src = g("lukas-reineke/virt-column.nvim"),
        data = {
            event = "IdeDeferred",
            after = function(_, opts)
                require("virt-column").setup(opts)
            end,
        },
    },
    --- Ident Guides
    {
        src = g("lukas-reineke/indent-blankline.nvim"),
        data = {
            event = "IdeDeferred",
            after = function(_, opts)
                require("ibl").setup(opts)
            end,
        },
    },
    --- Highlight search results and provide a nice UI for it
    --- Required by: nvim-scrollbar
    {
        src = g("kevinhwang91/nvim-hlslens"),
        data = {
            event = "IdeDeferred",
            -- after = function(_, opts)
            --     require("hlslens").setup(opts)
            -- end,
        },
    },
    --- Ripgrep/gitgrep source for the blink.cmp
    { src = g("mikavilpas/blink-ripgrep.nvim"), data = { event = "IdeDeferred" } },
    --- Set of preconfigured snippets for different languages.
    { src = g("rafamadriz/friendly-snippets"), data = { event = "IdeDeferred" } },
    --- Configurable GitHub Copilot blink.cmp source
    { src = g("fang2hou/blink-copilot"), data = { event = "IdeDeferred" } },
    --- Performant, batteries-included completion
    {
        src = g("saghen/blink.cmp"),
        version = vim.version.range("1.*"),
        data = {
            opts_extend = { "sources.default" },
            event = { "InsertEnter", "CmdlineEnter" },
            after = function(_, opts)
                opts.appearance.highlight_ns = vim.api.nvim_create_namespace("blink_cmp")
                local setup = false
                utils.run.on_load("jb.nvim", function()
                    -- Handle icons
                    opts.appearance.kind_icons = require("jb.icons").kind
                    -- Handle borders
                    local border = require("jb.borders").borders.dialog.default_box_shadowed
                    opts.completion.documentation.window.border = border
                    opts.completion.menu.border = border

                    require("blink.cmp").setup(opts)
                    setup = true
                end)
                if not setup then
                    require("blink.cmp").setup(opts)
                end
            end,
        },
    },
    --- Problems tool window
    {
        src = g("folke/trouble.nvim"),
        data = {
            -- enabled = false,
            event = "IdeDeferred",
            after = function(_, opts)
                local trouble = require("trouble")
                local ran_setup = false
                utils.run.on_load("jb.nvim", function()
                    opts.icons = { kinds = require("jb.icons").kind }
                    trouble.setup(opts)
                    ran_setup = true
                end)
                if not ran_setup then
                    trouble.setup(opts)
                end
            end,
        },
    },
    --- Better way to select, move, swap, and peek function blocks, classes, etc.
    {
        src = g("nvim-treesitter/nvim-treesitter-textobjects"),
        data = {
            opts = {
                select = { lookahead = true, include_surrounding_whitespace = false },
                move = { set_jumps = true },
            },
            before = function()
                vim.g.no_plugin_maps = true
            end,
            after = function(_, opts)
                require("nvim-treesitter-textobjects").setup(opts)
            end,
        },
    },
    --- Sticky Lines
    {
        src = g("nvim-treesitter/nvim-treesitter-context"),
        data = {
            event = "IdeDeferred",
            after = function(_, opts)
                require("treesitter-context").setup(opts)
            end,
        },
    },
    --- Promise & Async in Lua
    --- Required by: nvim-ufo
    { src = g("kevinhwang91/promise-async"), data = { event = "IdeDeferred" } },
    --- Better folding behavior with lots of behaviors defined in Utils.fold
    --- Requires: promise-async
    {
        src = g("kevinhwang91/nvim-ufo"),
        data = {
            event = "IdeDeferred",
            after = function(_, opts)
                require("ufo").setup(opts)
            end,
        },
    },
    --- Highlight, list and search todo comments in your projects
    --- Requires: plenary.nvim
    {
        src = g("folke/todo-comments.nvim"),
        data = {
            event = "IdeDeferred",
            after = function(_, opts)
                require("todo-comments").setup(opts)
            end,
        },
    },
    --- Smart and powerful comment plugin for neovim. Supports treesitter, dot repeat, left-right/up-down motions, hooks, and more
    {
        src = g("numToStr/Comment.nvim"),
        data = {
            event = "IdeDeferred",
            after = function(_, opts)
                require("Comment").setup(opts)
            end,
        },
    },
    --- Detect and chdir to the project root
    --- Using it in my own way only for root detection via both pattern and lsp
    --- See lua/settings/behavior/system.lua
    {
        src = g("DrKJeff16/project.nvim"),
        data = {
            -- Need to run it on UIEnter or later IdeDeferred to ensure that the first buffer is loaded
            event = "IdeDeferred",
            ---@param opts Project.Config.Options
            after = function(_, opts)
                opts.patterns = vim.list_extend(opts.patterns or {}, require("project.config.defaults").patterns)

                require("project").setup(opts)
            end,
        },
    },
    --- An asynchronous linter plugin for Neovim complementary to the built-in Language Server Protocol support.
    {
        src = g("mfussenegger/nvim-lint"),
        data = {
            event = { "BufReadPre", "BufNewFile" },
            after = function(_, opts)
                require("ide.lint").setup(opts)
            end,
        },
    },
    --- Lightweight yet powerful formatter
    {
        src = g("stevearc/conform.nvim"),
        data = {
            event = { "BufReadPre", "BufNewFile" },
            ---@type ide.Opts.Conform
            opts = {
                conform_opts = {
                    default_format_opts = {
                        stop_after_first = true,
                    },
                },
            },
            after = function(_, opts)
                require("ide.conform").setup(opts)
            end,
        },
    },
    --- Quickstart configs for Nvim LSP
    {
        src = g("neovim/nvim-lspconfig"),
        data = { -- Don't need to lazy load it because it's already lazy
            opts_extend = {
                "clients.eslint.enabled.1",
                "clients.vtsls.filetypes",
                "clients.vtsls.enabled.1",
                "clients.ts_ls.filetypes",
                "clients.ts_ls.enabled.1",
            },
            event = { "BufReadPre", "BufNewFile" },
            -- event = "IdeDeferred",
            after = function(_, opts)
                require("ide.lsp").setup(opts)
            end,
        },
    },
    --- Faster LuaLS setup
    --- Helps with go to definitons and references in lua
    {
        src = g("folke/lazydev.nvim"),
        data = {
            ft = "lua",
            after = function(_, opts)
                -- Make sure lazydev sets proper Lua.runtime.path
                require("lazydev.config").lua_root = false
                require("lazydev").setup(opts)
            end,
        },
    },
    --- Incremental LSP renaming based on Neovim's command-preview feature.
    {
        src = g("smjonas/inc-rename.nvim"),
        data = {
            event = "IdeDeferred",
            after = function(_, opts)
                require("inc_rename").setup(opts)
            end,
        },
    },
    --- Project View, Big file handling, image rendering, other stuff
    {
        src = g("nickkadutskyi/snacks.nvim"),
        data = {
            event = "IdeDeferred",
            after = function(_, opts)
                require("snacks").setup(opts)
            end,
        },
    },
    --- Fast File Finder for your AI and neovim, with memory built-in
    {
        src = g("dmtrKovalenko/fff.nvim"),
        data = {
            build = function()
                vim.notify("Downloading fff.nvim binary")
                -- this will download prebuild binary or try to use existing rustup toolchain to build from source
                -- (if you are using lazy you can use gb for rebuilding a plugin if needed)
                require("fff.download").download_or_build_binary()
            end,
            after = function(_, opts)
                -- we set this here to ensure proper root
                opts.base_path = vim.fn.getcwd()
                require("fff").setup(opts)
                -- NOTE: doing this to disable combo feature
                ---@diagnostic disable-next-line: duplicate-set-field
                require("fff.combo_renderer").detect_and_prepare = function() end
            end,
        },
    },
    -- Improved fzf.vim written in lua
    {
        src = g("ibhagwan/fzf-lua"),
        data = {
            event = "IdeDeferred",
            after = function(_, opts)
                local actions = require("fzf-lua.actions")

                -- adds ability to delete buffers in Switcher
                opts.buffers.actions = opts.buffers.actions or {}
                opts.buffers.actions["alt-backspace"] = { fn = actions.buf_del, reload = true }

                local setup = false
                utils.run.on_load("jb.nvim", function()
                    local split_top_shadowed = require("jb.borders").borders.dialog.default_box_split_top_shadowed
                    local split_bottom_shadowed = require("jb.borders").borders.dialog.default_box_split_bottom_shadowed
                    local header_shadowed = require("jb.borders").borders.dialog.default_box_header_shadowed
                    local icons = require("jb.icons")

                    opts.defaults.winopts.border = split_top_shadowed
                    opts.defaults.winopts.preview.border = split_bottom_shadowed
                    opts.buffers.winopts.border = header_shadowed

                    opts.lsp.symbols.symbol_icons = icons.kind

                    require("fzf-lua").setup(opts)
                    setup = true
                end)
                if not setup then
                    require("fzf-lua").setup(opts)
                end
            end,
        },
    },
    -- Simple winbar/statusline plugin that shows your current code context
    {
        src = g("SmiteshP/nvim-navic"),
        data = {
            event = "IdeDeferred",
            after = function(_, opts)
                local navic = require("nvim-navic")

                -- Adjusts icon for JSON objects
                local format_data = function(data, _)
                    if vim.bo.filetype == "json" then
                        for _, item in ipairs(data) do
                            if item.type == "Module" then
                                item.type = "Object"
                                item.kind = 19
                            end
                        end
                    end
                    return data
                end
                ---@diagnostic disable-next-line: duplicate-set-field
                navic.get_location = function(opts_internal, bufnr)
                    local data = navic.get_data(bufnr)
                    data = format_data(data, opts_internal)
                    return navic.format_data(data, opts_internal)
                end

                local setup = false
                utils.run.on_load("jb.nvim", function()
                    -- Sets icons from jb.nvim
                    opts.icons = vim.tbl_map(function(icon)
                        return icon ~= "" and icon .. " " or ""
                    end, require("jb.icons").kind)

                    navic.setup(opts)
                    setup = true
                end)
                if not setup then
                    navic.setup(opts)
                end
            end,
        },
    },
    -- Single tabpage interface for easily cycling through diffs for all modified files for any git rev.
    {
        src = g("sindrets/diffview.nvim"),
        data = {
            after = function(_, opts)
                require("diffview").setup(opts)
            end,
        },
    },
    -- Git integration for buffers
    {
        src = g("lewis6991/gitsigns.nvim"),
        data = {
            event = "IdeDeferred",
            after = function(_, opts)
                require("gitsigns").setup(opts)
            end,
        },
    },
    --- Error stripes and VCS status in Scrollbar
    --- Requires: nvim-hlslens, gitsigns.nvim
    {
        src = g("petertriho/nvim-scrollbar"),
        data = {
            event = "IdeDeferred",
            after = function(_, opts)
                require("scrollbar").setup(opts)
                require("scrollbar.handlers").register("under_caret", function(_)
                    return vim.g.highlighted_lines or {}
                end)
                require("scrollbar.handlers").register("todo", function(bufnr)
                    return (vim.g.todos_in_files or {})[vim.api.nvim_buf_get_name(bufnr)] or {}
                end)
            end,
        },
    },
})

local spec_builder = require("ide.spec.builder")
local utils = require("ide.utils")
local g = utils.str.prepend_fn("https://github.com/")
local c = utils.str.prepend_fn("https://codeberg.org/")

--- Define all plugins with their src here. Feature files patch via name only.
spec_builder.add({
    --- A library of lua functions used by lots of plugins
    --- Required by: harpoon
    { src = g("nvim-lua/plenary.nvim"), data = { deferred = false } },
    --- A notification manager with a nice UI
    ---TODO: move to snacks.nvim and style snacks.nvim notify or other notifications
    {
        src = g("rcarriga/nvim-notify"),
        version = "ab98fecfe",
        data = {
            deferred = false,
            after = function(_, opts)
                require("notify").setup(opts)
                vim.notify_orig = vim.notify
                vim.notify = require("notify")
                -- TODO: move this a different location
                local severity = { "error", "warn", "info", "info" }
                vim.lsp.handlers["window/showMessage"] = function(_, method, params)
                    local client = vim.lsp.get_client_by_id(params.client_id) or {}
                    vim.notify(method.message, severity[method.type], { title = "LSP: " .. (client.name or "Unknown") })
                end
            end,
        },
    },
    --- My color scheme that recreates IntelliJeJ's look and feel in Neovim
    {
        src = g("nickkadutskyi/jb.nvim"),
        data = { dev = true, deferred = false },
    },
    --- Gutter or statusline icons, Requires a Nerd Font.
    {
        src = g("nvim-tree/nvim-web-devicons"),
        data = {
            -- We load it synchronously because other plugins depend on it
            -- and might trigger setup before it's loaded, which would
            -- prevent them from applying the icon overrides
            deferred = false,
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
    --- Treesitter for syntax highlighting, folding, etc.
    --- Requires: tree-sitter, tar, curl, c compiler
    {
        src = g("nvim-treesitter/nvim-treesitter"),
        data = {
            opts_extend = { "ensure_installed" },
            build = function()
                vim.cmd("TSUpdate")
            end,
            ---@param opts ide.Opts.Treesitter
            after = function(_, opts)
                local uts = require("ide.utils").treesitter
                uts.ensure_installed(opts.ensure_installed)
                uts.create_auto_start_autocmd(opts)
                uts.setup_custom_parsers(opts.custom_parsers)
            end,
        },
    },
    --- Helps with go to definitons and references in lua
    {
        src = g("folke/lazydev.nvim"),
        data = {
            ft = "lua",
            after = function(_, opts)
                require("lazydev").setup(opts)
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
    -- LSP Progress lualine componenet
    -- Required by: lualine.nvim
    { src = g("arkav/lualine-lsp-progress"), data = { event = "IdeDeferred" } },
    --- Statusline configurator
    --- Requires: lualine-lsp-progress
    {
        src = g("nvim-lualine/lualine.nvim"),
        data = {
            -- TODO: run it defferred later when resolved conflict with harpoon-lualine
            event = "IdeDeferred",
            after = function(_, opts)
                -- Running it later to ensure that all components are registered
                -- because some may need to use lualine_require before lualine is setup
                utils.run.later(function()
                    -- TODO: check why I need this variables
                    _G._buffer_modified_count = 0
                    _G._buffer_modified_last_check_time = 0

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
    -- Status bar controller in the top right corner
    {
        src = g("b0o/incline.nvim"),
        data = {
            event = "IdeDeferred",
            after = function(_, opts)
                require("incline").setup(opts)
            end,
        },
    },
    -- Visual guides
    {
        src = g("lukas-reineke/virt-column.nvim"),
        data = {
            event = "IdeDeferred",
            after = function(_, opts)
                require("virt-column").setup(opts)
            end,
        },
    },
    -- Ident Guides
    {
        src = g("lukas-reineke/indent-blankline.nvim"),
        data = {
            event = "IdeDeferred",
            after = function(_, opts)
                require("ibl").setup(opts)
            end,
        },
    },
    -- Highlight search results and provide a nice UI for it
    -- Required by: nvim-scrollbar
    {
        src = g("kevinhwang91/nvim-hlslens"),
        data = {
            event = "IdeDeferred",
            -- after = function(_, opts)
            --     require("hlslens").setup(opts)
            -- end,
        },
    },
    -- Error stripes and VCS status in Scrollbar
    -- Requires: nvim-hlslens
    {
        src = g("petertriho/nvim-scrollbar"),
        data = {
            event = "IdeDeferred",
            after = function(_, opts)
                require("scrollbar").setup(opts)
                require("scrollbar.handlers").register("under_caret", function(bufnr)
                    return vim.g.highlighted_lines or {}
                end)
                require("scrollbar.handlers").register("todo", function(bufnr)
                    return (vim.g.todos_in_files or {})[vim.api.nvim_buf_get_name(bufnr)] or {}
                end)
            end,
        },
    },
    -- Ripgrep/gitgrep source for the blink.cmp
    { src = g("mikavilpas/blink-ripgrep.nvim"), data = { event = "IdeDeferred" } },
    -- Set of preconfigured snippets for different languages.
    { src = g("rafamadriz/friendly-snippets"), data = { event = "IdeDeferred" } },
    -- Configurable GitHub Copilot blink.cmp source
    { src = g("fang2hou/blink-copilot"), data = { event = "IdeDeferred" } },
    -- Performant, batteries-included completion
    {
        src = g("saghen/blink.cmp"),
        version = vim.version.range("1.*"),
        data = {
            opts_extend = { "sources.default" },
            event = "InsertEnter",
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
    -- Original modules from nvim-treesitter master branch
    -- Requires: nvim-treesitter
    {
        src = g("MeanderingProgrammer/treesitter-modules.nvim"),
        data = {
            event = "IdeDeferred",
            after = function(_, opts)
                require("treesitter-modules").setup(opts)
            end,
        },
    },
    -- Better way to select, move, swap, and peek function blocks, classes, etc.
    {
        src = g("nvim-treesitter/nvim-treesitter-textobjects"),
        data = {
            opts = {
                select = { lookahead = true, include_surrounding_whitespace = false },
                move = { set_jumps = true }
            },
            before = function()
                vim.g.no_plugin_maps = true
            end,
            after = function(_, opts)
                require("nvim-treesitter-textobjects").setup(opts)
            end,
        },
    },
})

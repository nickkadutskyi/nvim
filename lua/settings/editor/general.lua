local utils = require("ide.utils")
local spec_builder = require("ide.spec.builder")

--- AUTOCMDS -------------------------------------------------------------------

utils.run.now_if_arg_or_deferred(function()
    utils.autocmd.create({ "RecordingEnter", "RecordingLeave" }, {
        group = "settings.editor-macro-recording",
        desc = "Tracks macro recording status and stores it in a global variable for use in statusline",
        callback = function(e)
            if e.event == "RecordingEnter" then
                local register = vim.fn.reg_recording()
                _G._editor_macro_recording = register ~= "" and register or nil
            else
                _G._editor_macro_recording = nil
            end
        end,
    })
    utils.autocmd.create("BufRead", {
        group = "settings.readonly-dirs",
        desc = "Enforces readonly for files in vendor and node_modules",
        pattern = {
            "*/vendor/*",
            "*/node_modules/*",
        },
        callback = function(e)
            vim.opt_local.readonly = true
            vim.opt_local.modifiable = false
            vim.diagnostic.enable(false, { bufnr = e.buf })
            vim.opt_local.spell = false
        end,
    })
end)

--- Appearance --------------------------------------------------------------------

spec_builder.add({
    "indent-blankline.nvim",
    ---@type ibl.config
    opts = {
        indent = { char = "▏", tab_char = "▏" },
        -- disables underline
        scope = { char = "▏", show_start = false, show_end = false },
    },
})
spec_builder.add({
    "nvim-scrollbar",
    opts = {
        show = true,
        set_highlights = false,
        hide_if_all_visible = false,
        handlers = {
            diagnostic = true,
            gitsigns = true, -- Requires gitsigns
            handle = true,
            search = true, -- Requires hlslens
            cursor = false,
        },
        excluded_filetypes = { "snacks_picker_list" },
        marks = {
            GitAdd = {
                text = "│",
            },
            GitChange = {
                text = "│",
            },
            IdentifierUnderCaret = {
                text = { "-", "=" },
                priority = 1,
                gui = nil,
                color = nil,
                cterm = nil,
                color_nr = nil, -- cterm
                highlight = "IdentifierUnderCaret",
            },
            Todo = {
                text = { "-", "=" },
                priority = 1,
                gui = nil,
                color = nil,
                cterm = nil,
                color_nr = nil, -- cterm
                highlight = "Todo",
            },
        },
    },
})

--- Code Complection -----------------------------------------------------------

spec_builder.add({
    "blink.cmp",
    opts = {
        -- All presets have the following mappings:
        -- C-space: Open menu or open docs if already open
        -- C-n/C-p or Up/Down: Select next/previous item
        -- C-e: Hide menu
        -- C-k: Toggle signature help (if signature.enabled = true)
        -- See :h blink-cmp-config-keymap for defining your own keymap
        keymap = {
            preset = "default",
            ["<C-a>"] = { "show", "show_documentation", "hide_documentation" },
        },

        completion = {
            documentation = {
                -- Shows documentation pop-up automatically when available
                auto_show = true,
                window = { border = "rounded", scrollbar = false, max_width = 100 },
            },
            menu = {
                scrollbar = false,
                border = "rounded",
                auto_show = true,
                draw = {
                    columns = {
                        { "kind_icon" },
                        { "label", "label_description" },
                    },
                },
            },
        },

        -- Default list of enabled providers defined so that you can extend it
        -- elsewhere in your config, without redefining it, due to `opts_extend`
        sources = {
            default = { "lsp", "copilot", "path", "snippets", "buffer", "ripgrep" },
            per_filetype = {
                lua = { "lazydev", "lsp", "copilot", "path", "snippets", "buffer", "ripgrep" },
                ["99prompt"] = { "99", "lsp", "path", "buffer" },
            },
            providers = {
                ["99"] = {
                    name = "99",
                    module = "blink.compat.source",
                    score_offset = -3,
                    opts = {},
                },
                copilot = {
                    name = "copilot",
                    module = "blink-copilot",
                    async = true,
                    score_offset = -1,
                },
                lsp = { fallbacks = {} },
                lazydev = {
                    name = "LazyDev",
                    module = "lazydev.integrations.blink",
                    score_offset = 100,
                },

                -- Disabled because slow in large projects
                ripgrep = {
                    module = "blink-ripgrep",
                    name = "Ripgrep",
                    ---@module "blink-ripgrep"
                    ---@type blink-ripgrep.Options
                    opts = {},
                    score_offset = -5,
                },

                snippets = {
                    opts = {
                        friendly_snippets = true, -- default

                        -- see the list of frameworks in: https://github.com/rafamadriz/friendly-snippets/tree/main/snippets/frameworks
                        -- and search for possible languages in: https://github.com/rafamadriz/friendly-snippets/blob/main/package.json
                        -- the following is just an example, you should only enable the frameworks that you use
                        extended_filetypes = {
                            markdown = { "jekyll" },
                            sh = { "shelldoc" },
                            php = { "phpdoc" },
                            cpp = { "unreal" },
                            javascript = { "jsdoc" },
                            lua = { "luadoc" },
                            typescript = { "tsdoc" },
                        },
                    },
                },
            },
        },
        snippets = { preset = "default" },

        -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
        -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
        -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
        --
        -- See the fuzzy documentation for more information
        fuzzy = { implementation = "prefer_rust_with_warning" },
        appearance = {
            -- highlight_ns = vim.api.nvim_create_namespace("blink_cmp"),
            -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
            -- Adjusts spacing to ensure icons are aligned
            nerd_font_variant = "mono",
        },
    },
})

--- Code Folding ---------------------------------------------------------------

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldcolumn = "1"
vim.opt.foldtext = ""
vim.opt.foldlevel = 99
-- Using ufo provider need a large value, feel free to decrease the value
vim.opt.foldlevelstart = 99
vim.opt.foldnestmax = 6
vim.opt.foldenable = true
-- Faster fold updates
vim.opt.foldopen = "block,hor,insert,jump,mark,percent,quickfix,search,tag,undo"
vim.opt.foldclose = "all"

-- Define folding method per filetype (max 2 providers)
local ftMap = {
    vim = "indent",
    python = { "treesitter", "indent" },
    lua = { "treesitter", "indent" },
    javascript = { "treesitter", "indent" },
    typescript = { "treesitter", "indent" },
    javascriptreact = { "treesitter", "indent" },
    typescriptreact = { "treesitter", "indent" },
    vue = { "indent", "treesitter" },
    json = { "treesitter", "indent" },
    jsonc = { "treesitter", "indent" },
    yaml = { "treesitter", "indent" },
    toml = { "treesitter", "indent" },
    rust = { "lsp", "treesitter" },
    go = { "lsp", "treesitter" },
    php = { "lsp", "treesitter" },
    ruby = { "treesitter", "indent" },
    c = { "lsp", "treesitter" },
    cpp = { "lsp", "treesitter" },
    java = { "lsp", "treesitter" },
    css = { "treesitter", "indent" },
    scss = { "treesitter", "indent" },
    html = { "treesitter", "indent" },
    xml = { "treesitter", "indent" },
    markdown = { "treesitter", "indent" },
    sh = { "treesitter", "indent" },
    zsh = { "treesitter", "indent" },
    fish = { "treesitter", "indent" },
    git = "",
    gitcommit = "",
    fff_list = "",
    fff_preview = "",
    fff_input = "",
    help = "indent",
    text = "indent",
}

spec_builder.add({
    "nvim-ufo",
    opts = {
        open_fold_hl_timeout = 150,
        enable_get_fold_virt_text = true,
        fold_virt_text_handler = Utils.fold.ufo_virt_text_handler_enhanced,
        close_fold_kinds_for_ft = {
            default = { "imports", "comment" },
            json = { "array" },
            jsonc = { "array" },
            c = { "comment", "region" },
            cpp = { "comment", "region" },
            java = { "comment", "imports" },
            javascript = { "comment", "imports" },
            typescript = { "comment", "imports" },
            vue = { "imports" },
            python = { "comment", "imports" },
            go = { "comment", "imports" },
            rust = { "comment", "imports" },
            php = { "imports" },
        },
        provider_selector = function(bufnr, filetype, buftype)
            if buftype ~= "" then
                return nil -- Don't use ufo in non-file buffers
            end
            return ftMap[filetype] or Utils.fold.ufo_provider_selector
        end,
    },
})

--- Editor Tabs ----------------------------------------------------------------

_G._ide_tabline = utils.tabline.tabline
vim.opt.tabline = "%!v:lua._ide_tabline()"

--- Soft wrap ------------------------------------------------------------------

vim.opt.wrap = false
-- Soft wrap at line break - disabled for now
vim.opt.linebreak = false
-- Better indentation for wrapped lines
if vim.fn.has("linebreak") == 1 then
    vim.opt.breakindent = true
    vim.opt.showbreak = "↳ "
    vim.opt.breakindentopt = { shift = 0, min = 20, sbr = true }
end

--- Sticky Lines ---------------------------------------------------------------

spec_builder.add({
    "nvim-treesitter-context",
    opts = {
        enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
        multiwindow = false, -- Enable multiwindow support.
        max_lines = 5, -- How many lines the window should span. Values <= 0 mean no limit.
        min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
        line_numbers = true,
        multiline_threshold = 1, -- Maximum number of lines to show for a single context
        trim_scope = "outer", -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
        mode = "topline", -- Line used to calculate context. Choices: 'cursor', 'topline'
        -- Separator between context and content. Should be a single character string, like '-'.
        -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
        separator = nil,
        zindex = 20, -- The Z-index of the context window
        on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
    },
})

---@type LazySpec
return {
    {
        "MeanderingProgrammer/treesitter-modules.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        ---@module 'treesitter-modules'
        ---@type ts.mod.UserConfig
        opts = {
            incremental_selection = {
                enable = true,
                disable = false,
                keymaps = {
                    init_selection = "<A-Up>",
                    node_incremental = "<A-Up>",
                    scope_incremental = "<A-s>",
                    node_decremental = "<A-Down>",
                },
            },
        },
    },
    -- Better way to select, move, swap, and peek function blocks, classes, etc.
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
        init = function()
            -- Disable entire built-in ftplugin mappings to avoid conflicts.
            -- See https://github.com/neovim/neovim/tree/master/runtime/ftplugin for built-in ftplugins.
            vim.g.no_plugin_maps = true

            -- Or, disable per filetype (add as you like)
            -- vim.g.no_python_maps = true
            -- vim.g.no_ruby_maps = true
            -- vim.g.no_rust_maps = true
            -- vim.g.no_go_maps = true
        end,
        config = function()
            -- -- configuration
            require("nvim-treesitter-textobjects").setup({
                select = {
                    -- Automatically jump forward to textobj, similar to targets.vim
                    lookahead = true,
                    -- You can choose the select mode (default is charwise 'v')
                    --
                    -- Can also be a function which gets passed a table with the keys
                    -- * query_string: eg '@function.inner'
                    -- * method: eg 'v' or 'o'
                    -- and should return the mode ('v', 'V', or '<c-v>') or a table
                    -- mapping query_strings to modes.
                    -- selection_modes = {
                    --     ["@parameter.outer"] = "v", -- charwise
                    --     ["@function.outer"] = "V", -- linewise
                    --     ["@class.outer"] = "<c-v>", -- blockwise
                    -- },
                    -- If you set this to `true` (default is `false`) then any textobject is
                    -- extended to include preceding or succeeding whitespace. Succeeding
                    -- whitespace has priority in order to act similarly to eg the built-in
                    -- `ap`.
                    --
                    -- Can also be a function which gets passed a table with the keys
                    -- * query_string: eg '@function.inner'
                    -- * selection_mode: eg 'v'
                    -- and should return true of false
                    include_surrounding_whitespace = false,
                },
                move = {
                    -- whether to set jumps in the jumplist
                    set_jumps = true,
                },
            })

            -- keymaps
            -- You can use the capture groups defined in `textobjects.scm`
            -- SELECTION
            vim.keymap.set({ "x", "o" }, "am", function()
                require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
            end)
            vim.keymap.set({ "x", "o" }, "im", function()
                require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
            end)
            vim.keymap.set({ "x", "o" }, "ac", function()
                require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects")
            end)
            vim.keymap.set({ "x", "o" }, "ic", function()
                require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects")
            end)
            -- You can also use captures from other query groups like `locals.scm`
            vim.keymap.set({ "x", "o" }, "as", function()
                require("nvim-treesitter-textobjects.select").select_textobject("@local.scope", "locals")
            end)

            -- MOVEMENT
            vim.keymap.set({ "n", "x", "o" }, "]m", function()
                require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer", "textobjects")
            end)
            vim.keymap.set({ "n", "x", "o" }, "]]", function()
                require("nvim-treesitter-textobjects.move").goto_next_start("@class.outer", "textobjects")
            end)
            vim.keymap.set({ "n", "x", "o" }, "]M", function()
                require("nvim-treesitter-textobjects.move").goto_next_end("@function.outer", "textobjects")
            end)
            vim.keymap.set({ "n", "x", "o" }, "][", function()
                require("nvim-treesitter-textobjects.move").goto_next_end("@class.outer", "textobjects")
            end)
            vim.keymap.set({ "n", "x", "o" }, "[m", function()
                require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer", "textobjects")
            end)
            vim.keymap.set({ "n", "x", "o" }, "[[", function()
                require("nvim-treesitter-textobjects.move").goto_previous_start("@class.outer", "textobjects")
            end)

            vim.keymap.set({ "n", "x", "o" }, "[M", function()
                require("nvim-treesitter-textobjects.move").goto_previous_end("@function.outer", "textobjects")
            end)
            vim.keymap.set({ "n", "x", "o" }, "[]", function()
                require("nvim-treesitter-textobjects.move").goto_previous_end("@class.outer", "textobjects")
            end)
        end,
    },
    -- Similar to Sticky Lines in Intellij
    {
        "nvim-treesitter/nvim-treesitter-context",
        enabled = true,
        config = function()
            require("treesitter-context").setup({
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
            })
        end,
    },
    -- Better folding behavior with lots of behaviors defined in Utils.fold
    {
        "kevinhwang91/nvim-ufo",
        dependencies = "kevinhwang91/promise-async",
        enabled = true,
        config = function()
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
            -- Enhanced folding keymaps
            vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "Open all folds" })
            vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "Close all folds" })
            vim.keymap.set("n", "zr", require("ufo").openFoldsExceptKinds, { desc = "Open folds except kinds" })
            vim.keymap.set("n", "zm", require("ufo").closeFoldsWith, { desc = "Close folds with" })
            vim.keymap.set("n", "zp", function()
                local winid = require("ufo").peekFoldedLinesUnderCursor()
                if not winid then
                    vim.lsp.buf.hover()
                end
            end, { desc = "Peek fold or hover" })

            require("ufo").setup({
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
            })
        end,
    },
}

---@type LazySpec
return {
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
                vue = { "lsp", "indent" },
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
                    vue = { "comment", "imports" },
                    python = { "comment", "imports" },
                    go = { "comment", "imports" },
                    rust = { "comment", "imports" },
                    php = { "imports" },
                },
                provider_selector = function(bufnr, filetype, buftype)
                    return ftMap[filetype] or Utils.fold.ufo_provider_selector
                end,
            })
        end,
    },
}

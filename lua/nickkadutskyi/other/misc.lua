-- Splits open in the right and bottom
vim.opt.splitbelow = true
vim.opt.splitright = true
-- Adds characters possible to be used in filenames
vim.opt.isfname:append("@-@")
-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- Highlights when yanking text
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking text",
    group = vim.api.nvim_create_augroup("nickkadutskyi-highlight-yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- Help window mappings
-- Close help with q or escape
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("nickkadutskyi-help-mappings", { clear = true }),
    pattern = "help",
    callback = function()
        -- Buffer-local mappings for help windows
        vim.keymap.set("n", "q", ":q<CR>", { buffer = true, silent = true, desc = "Close help window" })
        vim.keymap.set("n", "<Esc>", ":q<CR>", { buffer = true, silent = true, desc = "Close help window" })
    end,
})

-- Enfores readonly for files in vendor and node_modules
vim.api.nvim_create_autocmd("BufRead", {
    group = vim.api.nvim_create_augroup("nickkadutskyi-readonly-dirs", { clear = true }),
    pattern = {
        "*/vendor/*",
        "*/node_modules/*",
    },
    callback = function()
        vim.opt_local.readonly = true
        vim.opt_local.modifiable = false
    end,
})

---@type LazySpec
return {
    { -- For installing language servers, formatters, linters, DAPs
        "williamboman/mason.nvim",
        opts = { ui = { border = "rounded" } },
    },
    { -- Snacks.nvim version of bigfile
        "folke/snacks.nvim",
        ---@type snacks.Config
        opts = {
            ---@class snacks.bigfile.Config
            bigfile = { enabled = true },
        },
    },
    { -- Image Previewer for previewing images in fzf-lua
        "3rd/image.nvim",
        -- so that it doesn't build the rock https://github.com/3rd/image.nvim/issues/91#issuecomment-2453430239
        build = false,
        opts = { processor = "magick_cli" },
    },
    { -- Hides secrets in files to work in public places
        "laytan/cloak.nvim",
        config = function()
            require("cloak").setup({
                patterns = {
                    {
                        file_pattern = { ".env*", "*credentials*", "*.php*" },
                        cloak_pattern = (function()
                            local patterns = {}
                            for _, param in ipairs({
                                "APP_SECRET",
                                "DATABASE_URL",
                                ".*KEY.*",
                                ".*'key'.*",
                                ".*_key.*",
                                ".*SECRET.*",
                                ".*secret.*",
                                ".*TOKEN.*",
                                ".*token.*",
                                ".*VAPID.*",
                                ".*vapid.*",
                                "MAILER_DSN",
                            }) do
                                table.insert(patterns, {
                                    "(%s*['\"]+" .. param .. "['\"]+%s*[=][>]*%s*['\"]).+(['\"][,]*)",
                                    replace = "%1",
                                })
                                table.insert(patterns, {
                                    "(" .. param .. "%s*[=:]%s*).+",
                                    replace = "%1",
                                })
                            end
                            return patterns
                        end)(),
                        replace = nil,
                    },
                },
            })

            vim.keymap.set("n", "<leader>el", ":CloakPreviewLine<CR>", {
                noremap = true,
                desc = "Cloak: [e]expose hidden [l]ine",
            })
            vim.keymap.set("n", "<leader>te", ":CloakToggle<CR>", {
                noremap = true,
                desc = "Cloak: [t]oggle [e]xposure",
            })
        end,
    },
}

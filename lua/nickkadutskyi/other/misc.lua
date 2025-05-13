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

return {
    {
        -- Image Previewer
        "3rd/image.nvim",
        build = false, -- so that it doesn't build the rock https://github.com/3rd/image.nvim/issues/91#issuecomment-2453430239
        opts = {
            processor = "magick_cli",
        },
    },
    {
        -- Hides secrets in files
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
                                ".*key.*",
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

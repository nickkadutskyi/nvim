---@type LazySpec
return {
    { -- Snacks.nvim version of bigfile
        "folke/snacks.nvim",
        ---@type snacks.Config
        opts = {
            ---@class snacks.bigfile.Config
            bigfile = { enabled = true },
            -- Moves git status to the right side of the row numbers like in IntelliJ
            statuscolumn = {
                enabled = true,
                folds = {
                    open = true, -- show open fold icons
                    git_hl = true, -- use Git Signs hl for fold icons
                },
            },
        },
    },
    { -- Image Previewer for previewing images in fzf-lua
        "3rd/image.nvim",
        event = "VeryLazy",
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
                        file_pattern = { ".env*", "*credentials*" },
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

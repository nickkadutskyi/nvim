return {
    {
        -- My new color scheme inspired by IntelliJ
        "nickkadutskyi/jb.nvim",
        lazy = false,
        priority = 1000,
        opts = {},
        dev = true,
        config = function()
            vim.cmd("colorscheme jb")
        end,
    },
    {
        -- Auto dark mode
        "f-person/auto-dark-mode.nvim",
        config = function(_)
            -- vim.notify = require("notify")
            local theme = os.getenv("theme") or os.getenv("colorscheme_bg") or os.getenv("neovim_bg")
            -- Auto change background only if theme is not hardcoded
            if theme == nil then
                require("auto-dark-mode").setup({})
            else
                if theme == "light" or theme == "l" then
                    vim.o.background = "light"
                elseif theme == "dark" or theme == "d" then
                    vim.o.background = "dark"
                else
                    require("auto-dark-mode").setup({})
                    vim.notify(
                        string.format(
                            "Invalid theme: '%s'.\nKeeping current: '%s'.\nExpected: 'light', 'l', 'dark' or 'd'.",
                            theme,
                            vim.o.background
                        ),
                        vim.log.levels.WARN,
                        { title = "Plugin " .. _.name .. " config" }
                    )
                end
            end
        end,
    },
}
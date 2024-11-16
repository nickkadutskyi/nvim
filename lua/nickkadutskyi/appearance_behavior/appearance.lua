return {
    {
        -- Sync theme with OS
        "f-person/auto-dark-mode.nvim",
        config = function(_)
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
                    if vim.fn.has("macunix") == 1 then -- Sets default jb_style based on MacOs theme
                        if io.popen("defaults read -g AppleInterfaceStyle 2>/dev/null"):read() == "Dark" then
                            vim.o.background = "dark"
                        else
                            vim.o.background = "light"
                        end
                    end
                    require("auto-dark-mode").setup({})
                    vim.notify(
                        string.format(
                            "Invalid theme: '%s'.\nKeeping current: '%s'.\nExpected: 'light', 'l', 'dark' or 'd'.",
                            theme,
                            vim.o.background
                        ),
                        vim.log.levels.WARN,
                        { title = "Plugin " .. _.name .. " config()" }
                    )
                end
            end
        end,
    },
}

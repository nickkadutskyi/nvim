---@class kdtsk.utils.theme
local M = {}

---Get the system appearance on macOS
---WARNING: This is a blocking system call
---@return "dark" | "light"
function M.get_system_appearance_macos()
    -- Check if the system is macOS
    if vim.fn.has("macunix") == 1 then
        if io.popen("defaults read -g AppleInterfaceStyle 2>/dev/null"):read() == "Dark" then
            return "dark"
        end
        return "light"
    end
end

---Sets the background option based on environment variables
function M.set_opt_background()
    local valid_themes = { dark = true, light = true }
    local env_theme = os.getenv("theme") or os.getenv("colorscheme_bg") or os.getenv("neovim_bg")
    if env_theme == nil then
        vim.o.background = Utils.theme.get_system_appearance_macos()
    else
        if valid_themes[env_theme] then
            vim.o.background = env_theme
        else
            vim.o.background = Utils.theme.get_system_appearance_macos()
            vim.notify(
                string.format(
                    "Provided: '%s'.\nSet to: '%s'.\nExpected: 'light' or 'dark'.\n"
                        .. "Env vars: 'theme', 'colorscheme_bg' or 'neovim_bg'.",
                    env_theme,
                    vim.o.background
                ),
                vim.log.levels.WARN,
                { title = "Invalid theme from env" }
            )
        end
    end
end

return M

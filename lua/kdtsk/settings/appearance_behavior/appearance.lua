-- UI Options

if vim.env.TMUX then
    vim.api.nvim_create_autocmd("BufEnter", {
        callback = function()
            -- Rename tmux window using the evaluated titlestring
            vim.fn.system(string.format('tmux rename-window "%s"', Utils.ui.titlestring()))
        end,
    })
end

local function macos_background()
    if vim.fn.has("macunix") == 1 then -- Sets default jb_style based on MacOs theme
        if io.popen("defaults read -g AppleInterfaceStyle 2>/dev/null"):read() == "Dark" then
            vim.o.background = "dark"
        else
            vim.o.background = "light"
        end
    end
end
local function set_background(callback)
    -- looks for env variables to fore a specific background
    local theme = os.getenv("theme") or os.getenv("colorscheme_bg") or os.getenv("neovim_bg")
    if theme == nil then
        macos_background()
        return type(callback) == "function" and callback()
    else
        if theme == "light" or theme == "l" then
            vim.o.background = "light"
        elseif theme == "dark" or theme == "d" then
            vim.o.background = "dark"
        else
            macos_background()
            vim.notify(
                string.format(
                    "Invalid theme: '%s'.\nKeeping current: '%s'.\nExpected: 'light', 'l', 'dark' or 'd'.",
                    theme,
                    vim.o.background
                ),
                vim.log.levels.WARN,
                { title = "Appearance & Behavior | Appearance" }
            )
            return type(callback) == "function" and callback()
        end
    end
end

-- Mouse reporting
vim.opt.mouse = "a"
-- Check if Neovim is running RPC server
local servername = vim.fn.has("nvim-0.9") and vim.api.nvim_get_vvar("servername") or ""
set_background()

---@type LazySpec
return {
    {
        -- Sync theme with OS
        "f-person/auto-dark-mode.nvim",
        -- Only enable if Neovim is not running RPC server
        enabled = servername == "",
        config = function(_)
            -- Auto change background only if theme is not hardcoded
            set_background(function()
                require("auto-dark-mode").setup({})
            end)
        end,
    },
    {
        -- Better input and select popups
        "stevearc/dressing.nvim",
        opts = {
            select = {
                backend = { "fzf" },
            },
        },
    },
}

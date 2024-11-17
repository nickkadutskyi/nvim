-- UI Options
-- Removes cmd line to allow more space
vim.opt.cmdheight = 0
-- File name and path in Window header
vim.opt.title = true
vim.opt.titlestring = [[%{fnamemodify(getcwd(),':t')}%{expand('%:t')!=''?'  – '.v:lua.TitleString():''}]]
-- Ensures relative file path if there are multiple files with same name in project
function _G.TitleString()
    local rootPath = vim.fn.resolve(vim.fn.getcwd())
    local relativeFilePath = vim.fn.expand("%")
    local filePath = vim.fn.expand("%:p")
    local fileName = vim.fn.expand("%:t")
    local home = vim.env.HOME .. "/"
    local all_files_str = vim.g.all_files_str or ""

    -- If Neovim didn't define all_files_str variable
    if all_files_str == "" then
        if string.match(filePath, "^" .. home) and vim.fn.resolve(filePath) ~= filePath then
            -- if file is in home directory and symlink
            return "./" .. vim.fn.fnamemodify(filePath, ":t")
        else
            return vim.fn.fnamemodify(vim.fn.resolve(filePath), ":~:.:h") .. "/" .. vim.fn.expand("%:t")
        end
    else
        -- Count occurrences of fileName in all_files_str
        local count = select(2, string.gsub(all_files_str, fileName, ""))

        if count > 1 then -- if other files with same name exist in project
            return vim.fn.fnamemodify(vim.fn.resolve(filePath), ":~:.:h") .. "/" .. vim.fn.expand("%:t")
        elseif count == 0 then -- if not in project
            if string.match(relativeFilePath, "^term://") then
                return "term " .. vim.fn.split(relativeFilePath, ":")[4]
            else
                return relativeFilePath .. " -[1]"
            end
        elseif string.sub(filePath, 1, #rootPath) == rootPath then -- if file is in root directory
            return fileName
        else
            return vim.fn.fnamemodify(vim.fn.resolve(filePath), ":~:.:h") .. "/" .. vim.fn.expand("%:t")
        end
    end
end

-- Mouse reporting
vim.opt.mouse = "a"

-- Lazy.nvim module
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
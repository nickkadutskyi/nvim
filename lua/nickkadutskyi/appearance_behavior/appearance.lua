-- UI Options
-- Cursor
-- vgcuim.opt.guicursor = "aaa::blinkon100"
vim.opt.guicursor = {
  'n-v-c:block-Cursor/lCursor-blinkon1',
  'i-ci-ve:ver25-Cursor/lCursor-blinkon1',
  'r-cr:hor20',
  'o:hor50',
  'a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor',
  'sm:block-blinkwait175-blinkoff150-blinkon175'
}
-- vim.opt.guicursor = {
--   'n-v-c:block-Cursor/lCursor-blinkon1',
--   'i-ci-ve:ver25-Cursor/lCursor-blinkon1',
--   't:ver25-Cursor/lCursor-blinkon1'
-- }
-- Removes cmd line to allow more space
vim.opt.cmdheight = 0
-- File name and path in Window header
vim.opt.title = true
vim.opt.titlestring = [[%{v:lua.TitleString()}]]
-- Ensures relative file path if there are multiple files with same name in project
function _G.TitleString()
    local devpath = vim.fn.fnamemodify("~/Developer", ":p")
    local cwd = vim.fn.getcwd()
    local projectName = vim.fn.fnamemodify(cwd, ":t")
    local project = projectName
    if cwd:find(devpath, 1, true) == 1 then
        local code = vim.fs.basename(vim.fs.dirname(cwd))
        code = tonumber(code) or code
        local account = vim.fs.basename(vim.fs.dirname(vim.fn.fnamemodify(cwd, ":h")))
        project = account .. "" .. code .. " " .. projectName
    end
    local rootPath = vim.fn.resolve(vim.fn.getcwd())
    local relativeFilePath = vim.fn.expand("%")
    local filePath = vim.fn.expand("%:p")
    local fileName = vim.fn.expand("%:t")
    local home = vim.env.HOME .. "/"
    local all_files_str = vim.g.all_files_str or ""
    local delim = fileName ~= "" and " – " or ""

    local title_filename
    -- If Neovim didn't define all_files_str variable
    if string.match(relativeFilePath, "^term://.*toggleterm#.*") then
        local path_parts = vim.fn.split(relativeFilePath, ":")
        local term_cmd = path_parts[#path_parts]
        local term_cmd_no_comments = term_cmd:gsub("%s*;.*", "")
        return "term " .. (vim.b.toggle_number or "") .. ": " .. term_cmd_no_comments
    elseif string.match(relativeFilePath, "^term://") then
        local path_parts = vim.fn.split(relativeFilePath, ":")
        title_filename = "term " .. path_parts[#path_parts]
    elseif string.match(relativeFilePath, "^.*://") then
        title_filename = relativeFilePath
    elseif all_files_str == "" then
        if string.match(filePath, "^" .. home) and vim.fn.resolve(filePath) ~= filePath then
            -- if file is in home directory and symlink
            title_filename = "./" .. vim.fn.fnamemodify(filePath, ":t")
        else
            title_filename = vim.fn.fnamemodify(vim.fn.resolve(filePath), ":~:.:h") .. "/" .. vim.fn.expand("%:t")
        end
    else
        -- Count occurrences of fileName in all_files_str
        local count = select(2, string.gsub(all_files_str, fileName, ""))

        if count > 1 then -- if other files with same name exist in project
            title_filename = vim.fn.fnamemodify(vim.fn.resolve(filePath), ":~:.:h") .. "/" .. vim.fn.expand("%:t")
        elseif count == 0 then -- if not in project
            if string.match(relativeFilePath, "^term://") then
                local path_parts = vim.fn.split(relativeFilePath, ":")
                title_filename = "term " .. path_parts[#path_parts]
            else
                title_filename = relativeFilePath
            end
        elseif string.sub(filePath, 1, #rootPath) == rootPath then -- if file is in root directory
            title_filename = fileName
        else
            title_filename = vim.fn.fnamemodify(vim.fn.resolve(filePath), ":~:.:h") .. "/" .. vim.fn.expand("%:t")
        end
    end
    -- return project .. (delim ~= "" and delim .. title_filename or "")
    return project .. " - " .. title_filename
end

if vim.env.TMUX then
    vim.api.nvim_create_autocmd("BufEnter", {
        callback = function()
            -- Rename tmux window using the evaluated titlestring
            vim.fn.system(string.format('tmux rename-window "%s"', _G.TitleString()))
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

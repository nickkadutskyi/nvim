--- Appearance & Behavior

--- - Appearance
--- -- UI Options
-- Mouse reporting
vim.opt.mouse = "a"
-- Removes cmd line to allow more space
vim.opt.cmdheight = 0
-- File name and path in Window header
vim.opt.title = true
vim.opt.titlestring = [[%{v:lua.Utils.ui.titlestring()}]]
-- Splits open in the right and bottom
vim.opt.splitbelow = true
vim.opt.splitright = true
-- Adds characters possible to be used in filenames
vim.opt.isfname:append("@-@")
-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

--- - Natural Language
vim.opt.spell = true
vim.opt.spelllang = { "en_us", "en", "ru", "uk" }
vim.opt.spellfile = os.getenv("HOME") .. "/.config/nvim_spell/en.utf-8.add"

--- - Local History
local vim_dir = os.getenv("HOME") .. "/.vim"
vim.o.undodir = vim_dir .. "/undo"
vim.o.directory = vim_dir .. "/swap"
vim.o.undofile = true
vim.o.swapfile = true
vim.o.updatetime = 250
vim.o.backup = false

--- Keymap
-- leader needs to be set before loading any plugin or module
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
-- Delays before mapped sequence to complete
vim.o.timeoutlen = 300

--- Editor
--- - Config
-- Soft wrap
vim.opt.wrap = false
-- Soft wrap at line break - disabled for now
vim.opt.linebreak = false
-- Better indentation for wrapped lines
if vim.fn.has("linebreak") == 1 then
    vim.opt.breakindent = true
    vim.opt.showbreak = "↳ "
    vim.opt.breakindentopt = { shift = 0, min = 20, sbr = true }
end


--- Plugins

--- - General
-- Sets caret blinking pattern
vim.opt.guicursor = {
    "n-v-c:block-Cursor/lCursor-blinkon1",
    "i-ci-ve:ver25-Cursor/lCursor-blinkon1",
    "r-cr:hor20",
    "o:hor50",
    "a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor",
    "sm:block-blinkwait175-blinkoff150-blinkon175",
}

--- - Appearance
-- Sign column always visible
vim.o.signcolumn = "yes"
-- Show line numbers
vim.o.number = true
-- Show line numbers relative to the cursor position
vim.o.relativenumber = true
-- Sets how Neovim will display certain whitespace characters in the editor.
vim.o.list = true
vim.opt.listchars = {
    tab = "» ",
    space = "‧",
    trail = "‧",
    extends = "⟩",
    nbsp = "␣",
}
-- Enables cursor line highlight groups
vim.o.cursorline = true
-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 3
-- Adds visual guides
-- vim.opt.colorcolumn = "80,100,120" -- defined via plugin
-- Removes chars from empty lines
vim.opt.fillchars = { eob = " " }

--- - Font
vim.g.nerd_font_is_present = true

--- Version control

--- Languages and frameworks

--- Tools

--- Backup & Sync

--- Advanced Settings

--- Other Settings

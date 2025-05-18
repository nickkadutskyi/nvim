-- Appearance and behavior

--- Appearance
---- UI Options
----- Removes cmd line to allow more space
vim.opt.cmdheight = 0
----- File name and path in Window header
vim.opt.title = true
vim.opt.titlestring = [[%{v:lua.TitleString()}]]

--- Natural Language
vim.opt.spell = true
vim.opt.spelllang = { "en_us", "en", "ru", "uk" }
vim.opt.spellfile = os.getenv("HOME") .. "/.config/nvim_spell/en.utf-8.add"

-- Keymap
-- leader needs to be set before loading any plugin or module
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"


-- Editor

--- General
----- Sets caret blinking pattern
vim.opt.guicursor = {
    "n-v-c:block-Cursor/lCursor-blinkon1",
    "i-ci-ve:ver25-Cursor/lCursor-blinkon1",
    "r-cr:hor20",
    "o:hor50",
    "a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor",
    "sm:block-blinkwait175-blinkoff150-blinkon175",
}
--- Font
vim.g.nerd_font_is_present = true

-- Version control

-- Languages and frameworks

-- Tools

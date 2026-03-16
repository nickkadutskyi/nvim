local utils = require("ide.utils")
local spec = require("ide.spec.builder")

--- AUTOCMDS -------------------------------------------------------------------

utils.run.now_if_arg_or_deferred(function()
    if os.getenv("TMUX") then
        utils.autocmd.create("BufEnter", {
            group = "settings.tmux-window-name",
            desc = "Set tmux window name to the current buffer name",
            callback = function()
                -- FIXME: cache titlestring somewhere to avoid re-evaluating it
                -- TODO: should I make async system call?
                -- Rename tmux window using the evaluated titlestring
                vim.fn.system(string.format('tmux rename-window "%s"', Utils.ui.titlestring()))
            end,
        })
    end
end)

--- OPTIONS --------------------------------------------------------------------

utils.run.later(function()
    require("vim._core.ui2").enable({
        enable = true,
        msg = {
            targets = {
                bufwrite = "msg",
                undo = "msg",
            },
            timeout = 4000,
        },
    })
end)

vim.o.pummaxwidth = 100 -- Limit maximum width of popup menu
vim.o.completetimeout = 100
vim.o.pumborder = "bold" -- Use border in built-in completion menu

-- Messaging
vim.opt.shortmess:append("I")
vim.opt.report = 20 -- to suppress message after yanking
-- Mouse reporting
vim.opt.mouse = "a"
-- Removes cmd line to allow more space
vim.opt.cmdheight = 0
-- File name and path in Window header
vim.opt.title = true
-- TODO: move titlestring function to ide.utils and use it here
vim.opt.titlestring = [[%{v:lua.Utils.ui.titlestring()}]]
-- Splits open in the right and bottom
vim.opt.splitbelow = true
vim.opt.splitright = true
-- Adds characters possible to be used in filenames
vim.opt.isfname:append("@-@")
-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"
-- Scrolling
vim.opt.termsync = false

--- General
-- Sets caret blinking pattern
vim.opt.guicursor = {
    "n-v-c:block-Cursor/lCursor-blinkon1",
    "i-ci-ve:ver25-Cursor/lCursor-blinkon1",
    "r-cr:hor20",
    "o:hor50",
    "a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor",
    "sm:block-blinkwait175-blinkoff150-blinkon175",
}

-- Sign column always visible
vim.o.signcolumn = "yes"
-- Show line numbers
vim.o.number = true
-- Show line numbers relative to the cursor position
vim.o.relativenumber = true
-- Sets how Neovim will display certain whitespace characters in the editor.
vim.o.list = true
vim.opt.listchars = {
    -- tab = "» ",
    tab = "——-",
    -- tab = "——–",
    -- tab = "──",
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
vim.opt.fillchars = { eob = " ", diff = "━" }

--- Font
vim.g.nerd_font_is_present = true

--- PLUGINS --------------------------------------------------------------------

local utils = require("ide.utils")

--- OPTIONS --------------------------------------------------------------------

-- Messaging
vim.opt.shortmess:append("I")
-- Mouse reporting
vim.opt.mouse = "a"
-- Removes cmd line to allow more space
-- Moved this to later event to avoid '"[No Name]" --No lines in buffer--' message
-- vim.opt.cmdheight = 0
utils.run.later(function()
    -- Setting it here delayed to avoid '"[No Name]" --No lines in buffer--' message
    vim.opt.cmdheight = 0
end)
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

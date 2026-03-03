--- OPTIONS --------------------------------------------------------------------

--- Code Folding
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldcolumn = "1"
vim.opt.foldtext = ""
vim.opt.foldlevel = 99
-- Using ufo provider need a large value, feel free to decrease the value
vim.opt.foldlevelstart = 99
vim.opt.foldnestmax = 6
vim.opt.foldenable = true
-- Faster fold updates
vim.opt.foldopen = "block,hor,insert,jump,mark,percent,quickfix,search,tag,undo"
vim.opt.foldclose = "all"

--- Config
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

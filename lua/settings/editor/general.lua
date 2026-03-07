local utils = require("ide.utils")

--- AUTOCMDS -------------------------------------------------------------------

utils.run.now_if_arg_or_deferred(function()
    utils.autocmd.create({ "RecordingEnter", "RecordingLeave" }, {
        group = "settings.editor-macro-recording",
        desc = "Tracks macro recording status and stores it in a global variable for use in statusline",
        callback = function(e)
            if e.event == "RecordingEnter" then
                local register = vim.fn.reg_recording()
                _G._editor_macro_recording = register ~= "" and register or nil
            else
                _G._editor_macro_recording = nil
            end
        end,
    })
    utils.autocmd.create("BufRead", {
        group = "settings.readonly-dirs",
        desc = "Enforces readonly for files in vendor and node_modules",
        pattern = {
            "*/vendor/*",
            "*/node_modules/*",
        },
        callback = function(e)
            vim.opt_local.readonly = true
            vim.opt_local.modifiable = false
            vim.diagnostic.enable(false, { bufnr = e.buf })
            vim.opt_local.spell = false
        end,
    })
end)

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

--- Editor Tabs

_G._ide_tabline = utils.tabline.tabline
vim.opt.tabline = "%!v:lua._ide_tabline()"

--- Soft wrap

vim.opt.wrap = false
-- Soft wrap at line break - disabled for now
vim.opt.linebreak = false
-- Better indentation for wrapped lines
if vim.fn.has("linebreak") == 1 then
    vim.opt.breakindent = true
    vim.opt.showbreak = "↳ "
    vim.opt.breakindentopt = { shift = 0, min = 20, sbr = true }
end

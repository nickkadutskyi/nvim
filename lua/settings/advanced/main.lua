local utils = require("ide.utils")

--- AUTOCMDS -------------------------------------------------------------------
utils.run.now_if_args(function()
    utils.autocmd.create({ "BufWritePre" }, {
        group = "settings.auto-create-dir",
        desc = "Auto create directory when saving a file",
        callback = function(event)
            if event.match:match("^%w%w+:[\\/][\\/]") then
                return
            end
            local file = vim.uv.fs_realpath(event.match) or event.match
            vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
        end,
    })
    utils.autocmd.create({ "FocusGained", "TermClose", "TermLeave" }, {
        group = "settings.checktime",
        desc = "Check if we need to reload the file when it changed",
        callback = function()
            if vim.o.buftype ~= "nofile" then
                vim.cmd("checktime")
            end
        end,
    })
    utils.autocmd.create("TextYankPost", {
        group = "settings.highlight-yank",
        desc = "Highlight yanked text",
        callback = function()
            (vim.hl or vim.highlight).on_yank()
        end,
    })
end)

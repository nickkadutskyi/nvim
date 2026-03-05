local utils = require("ide.utils")

--- AUTOCMDS -------------------------------------------------------------------

utils.run.now_if_args(function()
    utils.autocmd.create({ "BufEnter", "BufWritePost" }, {
        group = "settings.update-git-status-hl",
        callback = function(e)
            -- TODO: Move this from kdtsk to ide
            Utils.set_git_status_hl(e.buf)
        end,
    })
end)

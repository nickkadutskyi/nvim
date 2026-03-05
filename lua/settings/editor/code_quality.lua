local utils = require("ide.utils")

--- AUTOCMDS -------------------------------------------------------------------

utils.run.now_if_args(function()
    utils.autocmd.create({ "BufEnter" }, {
        group = "settings.turn-off-diagnostics-outside-projects",
        desc = "Disable diagnostics and spell checking for files outside of project root",
        callback = function(e)
            local root = vim.fn.getcwd()
            if not root or e.file and e.file ~= "" and not vim.startswith(e.file, root) then
                vim.diagnostic.enable(false, { bufnr = 0 })
                vim.opt_local.spell = false
            end
        end,
    })
end)

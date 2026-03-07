local utils = require("ide.utils")
local spec_builder = require("ide.spec.builder")

--- AUTOCMDS -------------------------------------------------------------------

utils.run.now_if_arg_or_deferred(function()
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

--- PLUGINS --------------------------------------------------------------------

spec_builder.add({
    "b0o/incline.nvim",
    opts = {
        render = function(props)
            return {
                { Utils.incline.component_diagnostics(props) },
            }
        end,
    },
})

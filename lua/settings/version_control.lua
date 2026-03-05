local spec_builder = require("ide.spec.builder")
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

--- PLUGINS --------------------------------------------------------------------

spec_builder.add({
    "nvim-treesitter",
    ---@type ide.Opts.Treesitter
    opts = {
        custom_parsers = {
            jjdescription = {
                install_info = {
                    url = "https://github.com/kareigu/tree-sitter-jjdescription", -- local path or git repo
                    revision = "1613b8c85b6ead48464d73668f39910dcbb41911",
                    branch = "dev", -- default branch in case of git repo if different from master
                },
                tier = 1,
            },
        },
    },
})

local spec = require("ide.spec.builder")
local utils = require("ide.utils")

--- AUTOCMDS -------------------------------------------------------------------

utils.run.now_if_arg_or_deferred(function()
    utils.autocmd.create({ "BufEnter", "BufWritePost" }, {
        group = "settings.update-git-status-hl",
        callback = function(e)
            -- TODO: Move this from kdtsk to ide
            Utils.set_git_status_hl(e.buf)
        end,
    })
end)

--- PLUGINS --------------------------------------------------------------------

spec.add({
    "nvim-treesitter",
    ---@type ide.Opts.Treesitter
    opts = {
        ensure_installed = {
            "jjdescription",
            "gitignore",
            "gitcommit",
            "git_config",
            "git_rebase",
            "diff",
        },
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
spec.add({
    "nvim-lint",
    ---@param opts ide.Opts.Lint
    opts = function(_, opts)
        local gitlint = require("lint").linters.gitlint

        gitlint.args = gitlint.args or {}

        vim.list_extend(gitlint.args, {
            -- "--staged",
            "--contrib",
            "CT1",
            "-c",
            "CT1.types=fix,feat,chore,docs,style,refactor,perf,test,revert,ci,build,wip",
            "--ignore",
            "T5,B6",
        })

        return vim.tbl_deep_extend("force", opts, {
            linters_by_ft = {
                gitcommit = { { "gitlint", nil, nil, true } },
            },
        })
    end,
})

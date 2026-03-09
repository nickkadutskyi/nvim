local spec_builder = require("ide.spec.builder")
local utils = require("ide.utils")

spec_builder.add({
    "DrKJeff16/project.nvim",
    ---@type Project.Config.Options
    opts = {
        patterns = { ">Documents" },
        manual_mode = true,
        disable_on = {
            ft = {
                "",
                "NvimTree",
                "TelescopePrompt",
                "TelescopeResults",
                "alpha",
                "checkhealth",
                "lazy",
                "log",
                "ministarter",
                "neo-tree",
                "notify",
                "nvim-pack",
                "packer",
                "qf",
            },
            bt = { "help", "nofile", "nowrite", "terminal" },
        },
    },
})

-- Corret root directory after project.nvim is loaded to use its patterns and lsp
utils.run.on_load("project.nvim", function()
    local project_api = require("project.api")

    local root, method = project_api.get_project_root()
    if root and root ~= vim.fn.getcwd() or false then
        -- vim.cmd.cd(root)
        project_api.set_pwd(root, method)
        vim.notify("Set project root to: " .. root, vim.log.levels.INFO, { title = "settings.behavior.system" })
    end
end, "settings.behavior.system: Failed to switch project root due to: ")

-- Need this to handle same filenames in title
-- TODO: make it more efficient, check if git is fast and also handle non-git project
utils.run.on_deferred(function()
    vim.system({ "git", "rev-parse", "--is-inside-work-tree" }, { text = true }, function(o)
        if o.code == 0 and o.stdout:match("true") then
            -- Checks if there are any files in git repo
            vim.system(
                { "sh", "-c", 'git -C "$(git rev-parse --show-toplevel)" ls-files | xargs basename' },
                { text = true },
                function(git_files)
                    if git_files.code == 0 then
                        -- Stores all files in git repo into global variable
                        vim.g.all_files_str = table.concat(vim.split(git_files.stdout, "\n"), ", ")
                    end
                end
            )
        end
    end)
end)

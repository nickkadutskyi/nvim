local spec = require("ide.spec.builder")
local utils = require("ide.utils")

spec.add({
    "DrKJeff16/project.nvim",
    ---@type Project.Config.Options
    opts = {
        patterns = {
            ">Documents",
            ".git",
            ".github",
            "_darcs",
            ".hg",
            ".bzr",
            ".svn",
            "Pipfile",
            "pyproject.toml",
            ".pre-commit-config.yaml",
            ".pre-commit-config.yml",
            ".csproj",
            ".sln",
            ".nvim.lua",
            ".neoconf.json",
            "neoconf.json",
        },
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
    -- local pr_core = require("project.core")
    --
    -- local root, method = pr_core.get_project_root()
    -- if root and root ~= vim.fn.getcwd() or false then
    --     -- vim.cmd.cd(root)
    --     pr_core.set_pwd(root, method)
    --     vim.notify("Set project root to: " .. root, vim.log.levels.INFO, { title = "settings.behavior.system" })
    -- end
end, "settings.behavior.system: Failed to switch project root due to: ")

-- Keep paths, not just basenames, so titles can use the shortest unique suffix.
utils.run.on_deferred(function()
    local generation = 0
    local function update_project_files()
        generation = generation + 1
        local request = generation
        local cwd = vim.fn.getcwd()
        local function store_files(result)
            if request ~= generation or vim.fn.getcwd() ~= cwd then
                return
            end
            vim.g.project_files = result.code == 0
                    and { root = cwd, paths = vim.split(result.stdout, "\0", { plain = true, trimempty = true }) }
                or nil
            vim.cmd.redraw()
        end
        vim.system(
            { "git", "ls-files", "--cached", "--others", "--exclude-standard", "-z" },
            { cwd = cwd },
            vim.schedule_wrap(function(result)
                if request ~= generation or vim.fn.getcwd() ~= cwd then
                    return
                end
                if result.code == 0 then
                    store_files(result)
                else
                    vim.system(
                        {
                            "rg",
                            "--files",
                            "--null",
                            "--hidden",
                            "--no-require-git",
                            "--glob",
                            "!.git",
                            "--glob",
                            "!.jj",
                        },
                        { cwd = cwd },
                        vim.schedule_wrap(function(files)
                            -- ripgrep exits with 1 when the project has no files.
                            if files.code == 1 then
                                files.code = 0
                            end
                            store_files(files)
                        end)
                    )
                end
            end)
        )
    end
    utils.autocmd.create({ "DirChanged", "BufWritePost", "FocusGained" }, {
        group = "settings.project-file-titles",
        desc = "Refresh project paths used to disambiguate file titles",
        callback = update_project_files,
    })
    update_project_files()
end)

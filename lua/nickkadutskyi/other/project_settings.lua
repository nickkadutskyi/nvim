return {
    {
        "ahmedkhalf/project.nvim",
        dependencies = {
            "ibhagwan/fzf-lua",
        },
        config = function()
            require("project_nvim").setup({
                manual_mode = true,
                detection_methods = { "pattern", "lsp" },
            })
            -- Change to project root on startup only
            vim.fn.timer_start(1, function()
                vim.cmd(":ProjectRoot")
            end)

            -- get a list of all git files into global variable
            -- Checks if it's a git repo
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

            -- KEYMAP

            -- Show Recent Projects
            vim.keymap.set("n", "<leader>srp", function()
                local uv = vim.uv or vim.loop
                local contents = require("project_nvim").get_recent_projects()
                local reverse = {}
                for i = #contents, 1, -1 do
                    local ok, path = pcall(uv.fs_realpath, contents[i])
                    if ok and path ~= contents[i] then
                        reverse[path] = true
                    else
                        reverse[contents[i]] = true
                    end
                end
                local reverseStrings = {}
                for k, _ in pairs(reverse) do
                    reverseStrings[#reverseStrings + 1] = k
                end
                require("fzf-lua").fzf_exec(reverseStrings, {
                    winopts = { title = " Recent Projects ", title_pos = "left" },
                    actions = {
                        ["default"] = function(e)
                            -- change cwd and open Explorer
                            vim.cmd(":cd " .. e[1] .. " | Explore")
                            -- change Explorer root to cwd
                            vim.cmd(":Ntree " .. e[1])
                            -- close all the buffers and keep current explorer
                            vim.cmd(":%bd|e .")
                        end,
                        ["ctrl-d"] = function(x)
                            local choice = vim.fn.confirm("Delete '" .. #x .. "' projects? ", "&Yes\n&No", 2)
                            if choice == 1 then
                                local history = require("project_nvim.utils.history")
                                for _, v in ipairs(x) do
                                    history.delete_project(v)
                                end
                            end
                        end,
                    },
                })
            end, { silent = true, desc = "[s]how [r]ecent [p]rojects" })
        end,
    },
}

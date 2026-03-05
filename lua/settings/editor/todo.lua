local utils = require("ide.utils")
local I = {}

--- AUTOCMDS -------------------------------------------------------------------
utils.run.now_if_arg_or_later(function()
    -- Populates `vim.g.todos_in_files` with lines of TODO comments
    -- to use to highlight scrollbar marks
    -- Activate Todo Comments integration only in allowed dirs
    I.allowed_check_todos = nil
    -- TODO: move Utils used here from kdtsk to ide
    utils.autocmd.create({ "BufWritePost", "BufReadPost" }, {
        group = "settings.check-todos",
        callback = function(_)
            if I.allowed_check_todos == nil then
                I.allowed_check_todos = Utils.is_path_in_paths(vim.fn.getcwd(), {
                    "~/Documents",
                    "~/.config/nvim",
                })
            end
            if I.allowed_check_todos then
                Utils.todo.add_todos_to_global()
            else
                vim.api.nvim_clear_autocmds({
                    group = "settings.check-todos",
                    pattern = "*",
                })
            end
        end,
    })
end)

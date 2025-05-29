---@class kdtsk.utils.todo
local M = {}

function M.add_todos_to_global()
    require("todo-comments.search").search(function(results)
        local todos_lines = {}
        for _, result in ipairs(results) do
            todos_lines[result.filename] = todos_lines[result.filename] or {}
            table.insert(todos_lines[result.filename], {
                line = result.lnum,
                type = "Todo",
            })
        end
        vim.g.todos_in_files = todos_lines
    end, { disable_not_found_warnings = true })
end

return M

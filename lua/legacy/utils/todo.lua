---@class kdtsk.utils.todo
local M = {}

function M.add_todos_to_global()
    local has_todo_search, todo_search = pcall(require, "todo-comments.search")
    if not has_todo_search then
        return
    end
    todo_search.search(function(results)
        local todos_lines = {}
        for _, result in ipairs(results) do
            todos_lines[result.filename] = todos_lines[result.filename] or {}
            table.insert(todos_lines[result.filename], {
                line = result.lnum - 1, -- v2 scrollbar marks are zero-based.
                type = "Todo",
            })
        end
        vim.g.todos_in_files = todos_lines
        if require("ide.pack").is_loaded("nvim-scrollbar") then
            require("scrollbar").refresh()
        end
    end, { disable_not_found_warnings = true })
end

return M

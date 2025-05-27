-- This file is automatically loaded by kdtsk.init

local function augroup(name, opts)
    return vim.api.nvim_create_augroup("kdtsk-" .. name, opts or { clear = true })
end

--- Appearance and Behavior

--- - Appearance
--- -- UI Options
-- Sets Tmux window name to the current buffer name when in tmux session
if os.getenv("TMUX") then
    vim.api.nvim_create_autocmd("BufEnter", {
        group = augroup("tmux-window-name"),
        callback = function()
            -- FIXME: cache titlestring somewhere to avoid re-evaluating it
            -- TODO: should I make async system call?
            -- Rename tmux window using the evaluated titlestring
            vim.fn.system(string.format('tmux rename-window "%s"', Utils.ui.titlestring()))
        end,
    })
end

-- Disable spell checking in terminal buffers
vim.api.nvim_create_autocmd({ "TermOpen" }, {
    group = augroup("term-spell-check"),
    callback = function()
        vim.opt_local.spell = false
    end,
})

--- Keymap

--- Editor
--- - Macro
-- Tracks macro recording status and stores it in a global variable for use in statusline
vim.api.nvim_create_autocmd({ "RecordingEnter", "RecordingLeave" }, {
    group = augroup("editor-macro-recording"),
    callback = function(e)
        if e.event == "RecordingEnter" then
            local register = vim.fn.reg_recording()
            _G._editor_macro_recording = register ~= "" and register or nil
        else
            _G._editor_macro_recording = nil
        end
    end,
})

--- Plugins
--- VCS
--- Build, Execution, Deployment

--- Languages & Frameworks

--- - Code Quality
-- Turns off diagnostics and spell checking for files outside of project root
vim.api.nvim_create_autocmd({ "BufEnter" }, {
    group = augroup("turn-off-diagnostics-outside-projects"),
    callback = function(e)
        local root = vim.fn.getcwd()
        if not root or not vim.startswith(e.file, root) then
            vim.diagnostic.enable(false, { bufnr = 0 })
            vim.opt_local.spell = false
        end
    end,
})

--- - Misc
-- Starts LSP logs rotation
Utils.on_later(function()
    Utils.lsp.rotate_lsp_logs()
    -- Set up a timer to rotate logs every hour
    vim.fn.timer_start(3600000, Utils.lsp.rotate_lsp_logs, { ["repeat"] = -1 })
end, vim.api.nvim_create_augroup("kdtsk-lsp-logs", { clear = true }))

--- Backup & Sync
--- - Advanced Settings

--- - Misc
-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    group = augroup("auto-create-dir"),
    callback = function(event)
        if event.match:match("^%w%w+:[\\/][\\/]") then
            return
        end
        local file = vim.uv.fs_realpath(event.match) or event.match
        vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
    end,
})
-- Populates `vim.g.todos_in_files` with lines of TODO comments
-- to use to highlight scrollbar marks
Utils.on_later(function()
    Utils.todo.add_todos_to_global()
    vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        group = augroup("check-todos"),
        callback = function(event)
            Utils.todo.add_todos_to_global()
        end,
    })
end, vim.api.nvim_create_augroup("kdtsk-todo-start", { clear = true }))

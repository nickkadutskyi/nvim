-- This file is automatically loaded by kdtsk.init

local function augroup(name)
    return vim.api.nvim_create_augroup("kdtsk-" .. name, { clear = true })
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

--- Plugin

--- Misc
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

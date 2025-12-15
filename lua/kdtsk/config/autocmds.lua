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
-- Close certain windows with q or escape
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("kdtsk-help-mappings", { clear = true }),
    pattern = {
        "PlenaryTestPopup",
        "checkhealth",
        "dbout",
        "gitsigns-blame",
        "grug-far",
        "help",
        "lspinfo",
        "neotest-output",
        "neotest-output-panel",
        "neotest-summary",
        "notify",
        "qf",
        "spectre_panel",
        "startuptime",
        "tsplayground",
        "lazy",
    },
    callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.schedule(function()
            local opts = { buffer = event.buf, silent = true, desc = "Buffer: [q/Esc] Close" }
            -- TODO: check if it's the last window in the tabpage, and if so, close the tabpage instead
            vim.keymap.set("n", "q", function()
                vim.cmd("close")
                pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
            end, opts)
            vim.keymap.set("n", "<Esc>", function()
                vim.cmd("close")
                pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
            end, opts)
        end)
    end,
})

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
        if not root or e.file and e.file ~= "" and not vim.startswith(e.file, root) then
            vim.diagnostic.enable(false, { bufnr = 0 })
            vim.opt_local.spell = false
        end
    end,
})

--- - Misc
-- Wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
    group = augroup("wrap-spell"),
    pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
    callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.spell = true
    end,
})

--- Backup & Sync

--- Advanced Settings
-- Enforces readonly for files in vendor and node_modules
vim.api.nvim_create_autocmd("BufRead", {
    group = augroup("readonly-dirs"),
    pattern = {
        "*/vendor/*",
        "*/node_modules/*",
    },
    callback = function()
        vim.opt_local.readonly = true
        vim.opt_local.modifiable = false
    end,
})

--- Other Settings
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
-- Activate Todo Comments integration only in allowed dirs
local group_check_todos = augroup("check-todos")
local allowed_check_todos = nil
vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
    group = group_check_todos,
    callback = function(_)
        if allowed_check_todos == nil then
            allowed_check_todos = Utils.is_path_in_paths(vim.fn.getcwd(), {
                "~/Documents",
                "~/.config/nvim",
                "~/.config/nixos-config",
            })
        end
        if allowed_check_todos then
            Utils.todo.add_todos_to_global()
        else
            vim.api.nvim_clear_autocmds({
                group = group_check_todos,
                pattern = "*",
            })
        end
    end,
})
-- Highlights when yanking text
vim.api.nvim_create_autocmd("TextYankPost", {
    group = augroup("highlight-yank"),
    callback = function()
        (vim.hl or vim.highlight).on_yank()
    end,
})
-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
    group = augroup("checktime"),
    callback = function()
        if vim.o.buftype ~= "nofile" then
            vim.cmd("checktime")
        end
    end,
})

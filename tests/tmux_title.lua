-- Run from the config root: nvim --headless -u NONE -l tests/tmux_title.lua
local config = vim.fn.getcwd()
vim.opt.rtp:prepend(config)
vim.env.SSH_CONNECTION = nil

local root = vim.fn.tempname()
vim.fn.mkdir(root, "p")
root = assert(vim.uv.fs_realpath(root))
local socket = "nvim-title-test-" .. vim.fn.getpid()
local function tmux(...)
    local command = { "tmux", "-L", socket, "-f", "/dev/null" }
    vim.list_extend(command, { ... })
    local result = vim.system(command, { text = true }):wait()
    assert(result.code == 0, result.stderr)
    return vim.trim(result.stdout)
end

local ok, err = xpcall(function()
    -- An isolated server keeps the test away from existing tmux sessions.
    tmux("new-session", "-d", "-s", "title-test", "cat")
    tmux("set-option", "-w", "automatic-rename", "off")
    vim.env.TMUX = tmux("display-message", "-p", "#{socket_path},#{pid}") .. ",0"
    vim.api.nvim_set_current_dir(root)
    vim.g.project_files = { root = root, paths = {} }
    _G.Utils = require("legacy.utils")
    require("settings.appearance.ui")
    vim.api.nvim_exec_autocmds("User", { pattern = "IdeDeferred" })

    for _, name in ipairs({
        "normal.lua",
        "$(touch pwned-dollar).lua",
        "`touch pwned-backtick`.lua",
        "$HOME.lua",
        'double"quote.lua',
        "single'quote.lua",
        "semi;colon.lua",
        "back\\slash.lua",
        "file with spaces.lua",
    }) do
        vim.fn.writefile({}, root .. "/" .. name)
        vim.cmd.edit(vim.fn.fnameescape(root .. "/" .. name))
        assert(vim.fn.filereadable(root .. "/pwned-dollar") == 0, "filename executed $() substitution")
        assert(vim.fn.filereadable(root .. "/pwned-backtick") == 0, "filename executed backtick substitution")
        local expected = vim.fs.basename(root) .. " - " .. name
        -- tmux itself escapes backslashes when storing window names.
        expected = expected:gsub("\\", "\\\\")
        local actual = tmux("display-message", "-p", "#{window_name}")
        assert(actual == expected, vim.inspect({ expected = expected, actual = actual }))
    end
    -- Entering a picker-like float must not rename the tmux window.
    local before = tmux("display-message", "-p", "#{window_name}")
    local win = vim.api.nvim_open_win(
        vim.api.nvim_create_buf(false, true),
        true,
        { relative = "editor", row = 1, col = 1, width = 20, height = 5 }
    )
    assert(tmux("display-message", "-p", "#{window_name}") == before)
    vim.api.nvim_win_close(win, true)

    vim.cmd.enew()
    local expected = vim.fs.basename(root) .. " - [no name]"
    local actual = tmux("display-message", "-p", "#{window_name}")
    assert(actual == expected, vim.inspect({ expected = expected, actual = actual }))
end, debug.traceback)

vim.system({ "tmux", "-L", socket, "kill-server" }):wait()
vim.api.nvim_set_current_dir(config)
vim.fn.delete(root, "rf")
assert(ok, err)
print("Literal tmux title checks passed")

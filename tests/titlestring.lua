-- Run from the config root: nvim --headless -u NONE -l tests/titlestring.lua
local config = vim.fn.getcwd()
vim.opt.rtp:prepend(config)
vim.env.SSH_CONNECTION = nil

local root = vim.fn.tempname()
local sibling = root .. "-other"
local plain = root .. "-plain"
local home = vim.env.HOME
local terminal_jobs = {}
local ui = require("legacy.utils.ui")
local function write(path)
    vim.fn.mkdir(vim.fs.dirname(path), "p")
    vim.fn.writefile({}, path)
end

local function title(path, expected)
    if path then
        vim.cmd.edit(vim.fn.fnameescape(path))
    else
        vim.cmd.enew()
    end
    local full = vim.fs.basename(vim.fn.getcwd()) .. " - " .. expected
    assert(ui.titlestring() == full, vim.inspect({ path = path, expected = full, actual = ui.titlestring() }))
    local evaluated =
        vim.api.nvim_eval_statusline('%{v:lua.require("legacy.utils.ui").titlestring()}', { maxwidth = 10000 }).str
    assert(evaluated == full, evaluated)
end

local ok, err = xpcall(function()
    title(nil, "[No Name]")
    local pattern_names = {
        "unfinished[",
        "unfinished(",
        "trailing%",
        "%f[",
        "%b(",
        "a.+*?-^$].lua",
        "%{1+1}.lua",
    }
    local paths = {
        "lua/legacy/utils/ui.lua",
        "lua/settings/appearance/ui.lua",
        "one/shared/deep/file.lua",
        "two/shared/deep/file.lua",
        "other/deep/file.lua",
        "main.lua",
        "src/main.lua",
        "vendor/src/main.lua",
        "domain.lua",
        "domainXlua",
        "a/[draft%.lua",
        "b/[draft%.lua",
        "a/rate%",
        "b/rate%",
        "a/file with spaces.lua",
        "b/file with spaces.lua",
        "unique.lua",
    }
    for _, name in ipairs(pattern_names) do
        table.insert(paths, "a/" .. name)
        table.insert(paths, "b/" .. name)
    end
    for _, path in ipairs(paths) do
        write(root .. "/" .. path)
    end
    root = assert(vim.uv.fs_realpath(root))
    sibling = root .. "-other"
    plain = root .. "-plain"
    assert(vim.system({ "git", "init", "-q", root }):wait().code == 0)
    assert(vim.system({ "git", "-C", root, "add", "lua", "a" }):wait().code == 0)
    -- An ignored duplicate must not affect a project file's title.
    write(root .. "/ignored/unique.lua")
    vim.fn.writefile({ "ignored/" }, root .. "/.gitignore")
    vim.api.nvim_set_current_dir(root)
    require("settings.behavior.system")
    vim.api.nvim_exec_autocmds("User", { pattern = "IdeDeferred" })
    assert(
        vim.wait(5000, function()
            return vim.g.project_files ~= nil and vim.g.project_files.root == root
        end),
        "initial project index missing"
    )

    title(nil, "[No Name]")
    -- An external symlink must retain its own path, even if its target is in the project.
    vim.fn.mkdir(sibling, "p")
    assert(vim.uv.fs_symlink(root .. "/unique.lua", sibling .. "/linked.lua"))
    vim.env.HOME = vim.fs.dirname(root)
    title(sibling .. "/linked.lua", "~/" .. vim.fs.basename(sibling) .. "/linked.lua")
    vim.env.HOME = home
    title(sibling .. "/linked.lua", sibling .. "/linked.lua")
    vim.api.nvim_buf_delete(0, { force = true })
    title("lua/legacy/utils/ui.lua", "utils/ui.lua")
    title("lua/settings/appearance/ui.lua", "appearance/ui.lua")
    title("one/shared/deep/file.lua", "one/shared/deep/file.lua")
    title("two/shared/deep/file.lua", "two/shared/deep/file.lua")
    title("other/deep/file.lua", "other/deep/file.lua")
    title("main.lua", "main.lua")
    title("src/main.lua", "src/main.lua")
    title("vendor/src/main.lua", "vendor/src/main.lua")
    title("domain.lua", "domain.lua")
    title("a/[draft%.lua", "a/[draft%.lua")
    title("b/rate%", "b/rate%")
    title("a/file with spaces.lua", "a/file with spaces.lua")
    title("unique.lua", "unique.lua")
    for _, name in ipairs(pattern_names) do
        title("a/" .. name, "a/" .. name)
        title("b/" .. name, "b/" .. name)
    end

    -- Non-file floats such as pickers keep the previous title; file floats still update it.
    title("lua/legacy/utils/ui.lua", "utils/ui.lua")
    local previous = ui.titlestring()
    local function float(buf)
        return vim.api.nvim_open_win(buf, true, { relative = "editor", row = 1, col = 1, width = 20, height = 5 })
    end
    for _, buf in ipairs({ vim.api.nvim_create_buf(false, true), vim.api.nvim_create_buf(false, false) }) do
        local win = float(buf)
        assert(ui.titlestring() == previous, ui.titlestring())
        vim.api.nvim_win_close(win, true)
    end
    local win = float(vim.api.nvim_create_buf(false, true))
    local float_job = vim.fn.jobstart({ vim.fn.exepath("sh") }, { term = true })
    terminal_jobs[#terminal_jobs + 1] = float_job
    assert(ui.titlestring() == previous, ui.titlestring())
    vim.fn.jobstop(float_job)
    vim.api.nvim_win_close(win, true)
    win = float(vim.fn.bufadd(root .. "/unique.lua"))
    assert(ui.titlestring() == vim.fs.basename(root) .. " - unique.lua", ui.titlestring())
    vim.api.nvim_win_close(win, true)
    assert(ui.titlestring() == previous, ui.titlestring())

    vim.cmd.edit("new/utils/ui.lua")
    vim.fn.mkdir(root .. "/new/utils", "p")
    vim.cmd.write()
    vim.cmd.edit("lua/legacy/utils/ui.lua")
    assert(
        vim.wait(5000, function()
            return ui.titlestring() == vim.fs.basename(root) .. " - legacy/utils/ui.lua"
        end),
        "saved duplicate did not refresh titles"
    )

    write(sibling .. "/unique.lua")
    title(sibling .. "/unique.lua", sibling .. "/unique.lua")
    assert(vim.system({ "git", "init", "-q", sibling }):wait().code == 0)
    vim.api.nvim_set_current_dir(sibling)
    assert(
        vim.wait(5000, function()
            return ui.titlestring() == vim.fs.basename(sibling) .. " - unique.lua"
        end),
        "changing projects did not refresh titles"
    )

    -- Without Git, scan hidden files while respecting both kinds of ignore files.
    for _, path in ipairs(paths) do
        write(plain .. "/" .. path)
    end
    for _, path in ipairs({ "ignored/unique.lua", "generated/unique.lua", ".git/unique.lua", ".jj/unique.lua" }) do
        write(plain .. "/" .. path)
    end
    vim.fn.writefile({ "ignored/" }, plain .. "/.gitignore")
    vim.fn.writefile({ "generated/" }, plain .. "/.ignore")
    write(plain .. "/.hidden/secret.lua")
    write(plain .. "/src/secret.lua")
    assert(vim.uv.fs_symlink(sibling, plain .. "/linked", { dir = true }))
    vim.api.nvim_set_current_dir(plain)
    assert(
        vim.wait(5000, function()
            return vim.g.project_files ~= nil and vim.g.project_files.root == plain
        end),
        "non-Git project index missing"
    )
    title("lua/legacy/utils/ui.lua", "utils/ui.lua")
    title("lua/settings/appearance/ui.lua", "appearance/ui.lua")
    title("one/shared/deep/file.lua", "one/shared/deep/file.lua")
    title("main.lua", "main.lua")
    title("src/main.lua", "src/main.lua")
    title("vendor/src/main.lua", "vendor/src/main.lua")
    title("a/[draft%.lua", "a/[draft%.lua")
    title("b/rate%", "b/rate%")
    title("a/file with spaces.lua", "a/file with spaces.lua")
    title(".hidden/secret.lua", ".hidden/secret.lua")
    title("src/secret.lua", "src/secret.lua")
    title("unique.lua", "unique.lua")
    for _, name in ipairs(pattern_names) do
        title("a/" .. name, "a/" .. name)
        title("b/" .. name, "b/" .. name)
    end

    -- External additions and removals should be reflected when focus returns.
    title("lua/legacy/utils/ui.lua", "utils/ui.lua")
    write(plain .. "/external/utils/ui.lua")
    vim.api.nvim_exec_autocmds("FocusGained", {})
    assert(
        vim.wait(5000, function()
            return ui.titlestring() == vim.fs.basename(plain) .. " - legacy/utils/ui.lua"
        end),
        "external duplicate did not refresh titles"
    )
    vim.fn.delete(plain .. "/external/utils/ui.lua")
    vim.api.nvim_exec_autocmds("FocusGained", {})
    assert(
        vim.wait(5000, function()
            return ui.titlestring() == vim.fs.basename(plain) .. " - utils/ui.lua"
        end),
        "removed duplicate still affects titles"
    )

    -- Show executable names, including programs launched by a shell, not arguments.
    vim.cmd.enew()
    local shell = vim.fn.exepath("sh")
    local job = vim.fn.jobstart({ shell, "-c", 'read -r command; eval "$command"' }, { term = true })
    assert(job > 0)
    terminal_jobs[#terminal_jobs + 1] = job
    local prefix = vim.fs.basename(plain) .. " - " .. vim.fs.basename(shell)
    assert(ui.titlestring() == prefix, ui.titlestring())
    vim.fn.chansend(job, vim.fn.shellescape(shell) .. " -c 'sleep 60 & wait' & wait\n")
    assert(
        vim.wait(5000, function()
            return ui.titlestring() == prefix .. " → sleep"
        end),
        "terminal title did not show the shell's running program: " .. ui.titlestring()
    )
    vim.fn.jobstop(job)
    assert(
        vim.wait(5000, function()
            return ui.titlestring() == prefix
        end),
        "exited terminal should fall back to the executable name: " .. ui.titlestring()
    )

    vim.fn.mkdir(plain .. "/empty")
    vim.api.nvim_set_current_dir(plain .. "/empty")
    assert(
        vim.wait(5000, function()
            local files = vim.g.project_files
            return files ~= nil and files.root == plain .. "/empty" and #files.paths == 0
        end),
        "empty non-Git project should have an empty index"
    )
end, debug.traceback)

for _, job in ipairs(terminal_jobs) do
    pcall(vim.fn.jobstop, job)
end
vim.env.HOME = home
vim.api.nvim_set_current_dir(config)
vim.fn.delete(root, "rf")
vim.fn.delete(sibling, "rf")
vim.fn.delete(plain, "rf")
assert(ok, err)
print("Shortest unique title checks passed")

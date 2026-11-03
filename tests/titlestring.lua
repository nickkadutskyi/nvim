-- Run from the config root: nvim --headless -u NONE -l tests/titlestring.lua
local config = vim.fn.getcwd()
vim.opt.rtp:prepend(config)
vim.env.SSH_CONNECTION = nil

local root = vim.fn.tempname()
local sibling = root .. "-other"
local plain = root .. "-plain"
local ui = require("legacy.utils.ui")
local function write(path)
    vim.fn.mkdir(vim.fs.dirname(path), "p")
    vim.fn.writefile({}, path)
end

local function title(path, expected)
    vim.cmd.edit(vim.fn.fnameescape(path))
    local full = vim.fs.basename(vim.fn.getcwd()) .. " - " .. expected .. " (nvim)"
    assert(ui.titlestring() == full, vim.inspect({ path = path, expected = full, actual = ui.titlestring() }))
    local evaluated =
        vim.api.nvim_eval_statusline('%{v:lua.require("legacy.utils.ui").titlestring()}', { maxwidth = 10000 }).str
    assert(evaluated == full, evaluated)
end

local ok, err = xpcall(function()
    local paths = {
        "lua/legacy/utils/ui.lua",
        "lua/settings/appearance/ui.lua",
        "one/shared/deep/file.lua",
        "two/shared/deep/file.lua",
        "other/deep/file.lua",
        "main.lua",
        "src/main.lua",
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
    for _, path in ipairs(paths) do
        write(root .. "/" .. path)
    end
    root = assert(vim.uv.fs_realpath(root))
    sibling = root .. "-other"
    plain = root .. "-plain"
    assert(vim.system({ "git", "init", "-q", root }):wait().code == 0)
    assert(vim.system({ "git", "-C", root, "add", "lua" }):wait().code == 0)
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

    title("lua/legacy/utils/ui.lua", "utils/ui.lua")
    title("lua/settings/appearance/ui.lua", "appearance/ui.lua")
    title("one/shared/deep/file.lua", "one/shared/deep/file.lua")
    title("two/shared/deep/file.lua", "two/shared/deep/file.lua")
    title("other/deep/file.lua", "other/deep/file.lua")
    title("main.lua", vim.fs.basename(root) .. "/main.lua")
    title("src/main.lua", "src/main.lua")
    title("domain.lua", "domain.lua")
    title("a/[draft%.lua", "a/[draft%.lua")
    title("b/rate%", "b/rate%")
    title("a/file with spaces.lua", "a/file with spaces.lua")
    title("unique.lua", "unique.lua")

    vim.cmd.edit("new/unique.lua")
    vim.fn.mkdir(root .. "/new", "p")
    vim.cmd.write()
    vim.cmd.edit("unique.lua")
    assert(
        vim.wait(5000, function()
            return ui.titlestring() == vim.fs.basename(root) .. " - " .. vim.fs.basename(root) .. "/unique.lua (nvim)"
        end),
        "saved duplicate did not refresh titles"
    )

    write(sibling .. "/unique.lua")
    title(sibling .. "/unique.lua", sibling .. "/unique.lua")
    assert(vim.system({ "git", "init", "-q", sibling }):wait().code == 0)
    vim.api.nvim_set_current_dir(sibling)
    assert(
        vim.wait(5000, function()
            return ui.titlestring() == vim.fs.basename(sibling) .. " - unique.lua (nvim)"
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
    title("a/[draft%.lua", "a/[draft%.lua")
    title("b/rate%", "b/rate%")
    title("a/file with spaces.lua", "a/file with spaces.lua")
    title(".hidden/secret.lua", ".hidden/secret.lua")
    title("src/secret.lua", "src/secret.lua")
    title("unique.lua", "unique.lua")

    -- External additions and removals should be reflected when focus returns.
    title("domain.lua", "domain.lua")
    write(plain .. "/external/domain.lua")
    vim.api.nvim_exec_autocmds("FocusGained", {})
    assert(
        vim.wait(5000, function()
            return ui.titlestring() == vim.fs.basename(plain) .. " - " .. vim.fs.basename(plain) .. "/domain.lua (nvim)"
        end),
        "external duplicate did not refresh titles"
    )
    vim.fn.delete(plain .. "/external/domain.lua")
    vim.api.nvim_exec_autocmds("FocusGained", {})
    assert(
        vim.wait(5000, function()
            return ui.titlestring() == vim.fs.basename(plain) .. " - domain.lua (nvim)"
        end),
        "removed duplicate still affects titles"
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

vim.api.nvim_set_current_dir(config)
vim.fn.delete(root, "rf")
vim.fn.delete(sibling, "rf")
vim.fn.delete(plain, "rf")
assert(ok, err)
print("Shortest unique title checks passed")

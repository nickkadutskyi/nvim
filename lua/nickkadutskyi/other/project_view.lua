-- TODO Add custom syntax regex to highlight files ignored by git
-- TODO Contribute to https://github.com/prichrd/netrw.nvim to get Git support
-- TODO keep the window open when marking directory as a target with `mt` in netrw to preserve state

local utils = require("nickkadutskyi.utils")

-- Netrw
vim.g.netrw_keepdir = 1 -- To avoid changing cwd when navigating in netrw
vim.g.netrw_banner = 0 -- remove the banner at the top
vim.g.netrw_preview = 1
vim.g.netrw_liststyle = 3 -- default directory view. Cycle with i
vim.g.netrw_fastbrowse = 2 -- Use fast browsing

local function close_project_view()
    if vim.t.project_view_winid ~= nil and vim.api.nvim_win_is_valid(vim.t.project_view_winid) then
        vim.api.nvim_win_close(vim.t.project_view_winid, true)
    end
    vim.t.project_view_winid = nil
    vim.t.project_view_winnr = nil
end

local function toggle_vim_explorer_float()
    -- Configures a proper window to open a file in after selection
    local _, open_in_winid = utils.get_win_with_normal_buffer(vim.api.nvim_get_current_buf())
    if open_in_winid ~= nil then
        vim.g.netrw_chgwin = vim.api.nvim_win_get_number(open_in_winid)
    end
    if vim.t.project_view_winid ~= nil then
        -- Close Netrw window if it's open
        close_project_view()
    else
        -- Create floating window
        local _, winid, winnr = utils.create_tool_window(
            "Project",
            "left",
            true,
            function(winid)
                vim.fn.win_execute(winid, "Explore")
            end,
            nil,
            function()
                -- Clear Netrw variables on close
                vim.t.project_view_winid = nil
                vim.t.project_view_winnr = nil
            end
        )
        vim.t.project_view_winid = winid
        vim.t.project_view_winnr = winnr
        -- Adds custom CursorLine highlight group
        vim.api.nvim_set_option_value(
            "winhl",
            (vim.api.nvim_get_option_value("winhl", { win = winid }) or "")
                .. ",CursorLine:NetrwCursorLine"
                .. ",CursorLineNr:NetrwCursorLine"
                .. ",CursorLineSign:NetrwCursorLine",
            { win = winid }
        )
    end
end

vim.keymap.set("n", "<leader>ap", toggle_vim_explorer_float, {
    desc = "Project: [a]ctivate [p]roject tool window.",
})
-- FIXME: This doesn't work
vim.keymap.set({ "n", "i" }, "<A-1>", toggle_vim_explorer_float, {
    desc = "Project: [a]ctivate [p]roject tool window.",
})

local group_start = vim.api.nvim_create_augroup("nickkadutskyi-netrw-start", { clear = true })
vim.api.nvim_create_autocmd("VimEnter", {
    group = group_start,
    callback = function(e)
        -- Clears Neovim's built-in group that triggers Netrw on directories
        vim.api.nvim_clear_autocmds({ group = "FileExplorer" })
        -- Opens Netrw on directories only on startup
        if vim.fn.isdirectory(vim.fn.expand("%:p")) == 1 then
            vim.schedule(function()
                toggle_vim_explorer_float()
            end)
        end
    end,
})

-- Global command to close Project view in other keybindings
vim.api.nvim_create_user_command("CloseProjectView", close_project_view, {})

---@type LazySpec
return {
    { -- Adds icons to Netrw
        "prichrd/netrw.nvim",
        opts = {
            -- File icons to use when `use_devicons` is false or if
            -- no icon is found for the given file type.
            icons = {
                symlink = " ",
                directory = " ",
                file = " ",
            },
            -- Uses mini.icon or nvim-web-devicons if true, otherwise use the file icon specified above
            use_devicons = true,
            mappings = {
                -- Function mappings receive an object describing the node under the cursor
                ["p"] = function(payload)
                    print(vim.inspect(payload))
                end,
                -- String mappings are executed as vim commands
                ["<Leader>p"] = ":echo 'hello world'<CR>",
            },
        },
    },
}

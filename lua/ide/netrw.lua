local utils = require("ide.utils")
local spec = require("ide.spec.builder")

--- MODULE DEFINITION ----------------------------------------------------------

local M = {}
local I = {}

---@type string?
I.current_file = nil
I.project_view_winid = nil
I.project_view_winnr = nil

function M.setup()
    -- Netrw Configs
    vim.g.netrw_keepdir = 1 -- To avoid changing cwd when navigating in netrw
    vim.g.netrw_banner = 0 -- remove the banner at the top
    vim.g.netrw_preview = 1
    vim.g.netrw_liststyle = 3 -- default directory view. Cycle with i
    vim.g.netrw_fastbrowse = 2 -- Use fast browsing

    spec.add({
        src = "https://github.com/prichrd/netrw.nvim",
        data = {
            event = "IdeDeferred",
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
                    -- -- Function mappings receive an object describing the node under the cursor
                    -- ["p"] = function(payload)
                    --     print(vim.inspect(payload))
                    -- end,
                    -- -- String mappings are executed as vim commands
                    -- ["<Leader>p"] = ":echo 'hello world'<CR>",
                },
            },
            after = function(_, opts)
                require("netrw").setup(opts)
            end,
        },
    })
end

function M.toggle_vim_explorer_float()
    -- Configures a proper window to open a file in after selection
    local _, open_in_winid = I.get_win_with_normal_buffer(vim.api.nvim_get_current_buf())
    if open_in_winid ~= nil then
        vim.g.netrw_chgwin = vim.api.nvim_win_get_number(open_in_winid)
    end
    if I.project_view_winid ~= nil then
        -- Close Netrw window if it's open
        I.close_project_view()
    else
        -- Create floating window
        local _, winid, winnr = Utils.create_tool_window(
            "Project",
            "left",
            true,
            function(winid)
                I.current_file = vim.fn.expand("%:p")
                local filename = vim.fn.fnamemodify(I.current_file, ":t")
                if vim.fn.isdirectory(I.current_file) == 1 or filename == "" then
                    vim.fn.win_execute(winid, "Explore")
                else
                    utils.run.later(function()
                        -- vim.fn.win_execute(winid, "ExploreFind")
                        I.explore_find()
                    end)
                end
            end,
            nil,
            function()
                -- Clear Netrw variables on close
                I.project_view_winid = nil
                I.project_view_winnr = nil
            end
        )
        I.project_view_winid = winid
        I.project_view_winnr = winnr
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

function I.explore_find()
    local current_file = I.current_file or vim.fn.expand("%:p")
    local filename = vim.fn.fnamemodify(current_file, ":t")
    local directory = vim.fn.fnamemodify(current_file, ":h")

    -- If no file is open or filename is empty, just open explorer without searching
    if filename == "" or current_file == "" then
        vim.cmd("Explore " .. (directory ~= "" and directory or "."))
    else
        vim.fn.setreg("/", filename) -- Set search register
        vim.cmd("Explore " .. directory)
        vim.cmd("normal n") -- Go to next search match
        vim.cmd("noh")
    end
    I.current_file = nil
end

---@param bufnr number
---@return boolean
function I.is_normal_buffer(bufnr)
    if vim.api.nvim_buf_is_valid(bufnr) then
        return vim.api.nvim_get_option_value("buftype", { buf = bufnr }) == "" and vim.fn.buflisted(bufnr) == 1
    end
    return false
end

---@param bufnr? number
---@return number?, number?
function I.get_win_with_normal_buffer(bufnr)
    if bufnr ~= nil and I.is_normal_buffer(bufnr) then
        return bufnr, vim.fn.bufwinid(bufnr)
    end
    -- local bufs = vim.fn.tabpagebuflist()
    local bufs = {}
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        bufs[vim.api.nvim_win_get_buf(win)] = win
        -- table.insert(bufs, vim.api.nvim_win_get_buf(win))
    end
    for buf, win in pairs(bufs) do
        if I.is_normal_buffer(buf) then
            return buf, win
        end
    end
    return nil, nil
end

function I.close_project_view()
    if I.project_view_winid ~= nil and vim.api.nvim_win_is_valid(I.project_view_winid) then
        vim.api.nvim_win_close(I.project_view_winid, true)
    end
    I.project_view_winid = nil
    I.project_view_winnr = nil
end

return M

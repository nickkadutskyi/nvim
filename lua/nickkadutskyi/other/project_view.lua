---Config

-- Netrw
vim.g.netrw_keepdir = 1 -- To avoid changing cwd when navigating in netrw
vim.g.window_id_before_netrw = nil

local function close_netrw()
    for bufn = 1, vim.fn.bufnr("$") do
        if vim.fn.bufexists(bufn) == 1 and vim.fn.getbufvar(bufn, "&filetype") == "netrw" then
            if vim.t.expl_buf_num then
                vim.t.expl_buf_num = nil
            end
            vim.cmd("silent! bwipeout " .. bufn)
            if vim.fn.getline(2):match('^" Netrw ') then
                vim.cmd("silent! bwipeout")
            end
            -- Switch to previous window
            if vim.g.window_id_before_netrw then
                vim.fn.win_gotoid(vim.g.window_id_before_netrw)
                vim.g.window_id_before_netrw = nil
            end
            return
        end
    end
end

-- File Browser toggle and keep its width consistent
local function toggle_vim_explorer()
    -- ID of the window before the switch to netrw
    vim.g.window_id_before_netrw = vim.fn.win_getid()
    if vim.t.expl_buf_num then
        close_netrw()
    else
        vim.cmd("1wincmd w")
        vim.cmd("Lexplore")
        -- After switching to netwr buff, lets resize to 45
        vim.cmd("vertical resize 45")
        vim.t.expl_buf_num = vim.fn.bufnr("%")
    end
end

vim.keymap.set("n", "<leader>fb", toggle_vim_explorer, { desc = "Toggle file browser" })

vim.api.nvim_create_user_command("CloseNetrw", close_netrw, {})

local function netrw_mapping()
    -- Buffer-local mappings
    vim.keymap.set("n", "<Esc>", close_netrw, { buffer = true, silent = true })
    vim.keymap.set("n", "q", close_netrw, { buffer = true, silent = true })

    -- Netrw settings
    vim.g.netrw_banner = 0 -- remove the banner at the top
    vim.g.netrw_preview = 1
    vim.g.netrw_liststyle = 3 -- default directory view. Cycle with i
end

-- Netrw mappings autogroup
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("nickkadutskyi-netrw-mappings", { clear = true }),
    pattern = "netrw",
    callback = netrw_mapping,
})

-- Close Netrw when selecting a file
vim.api.nvim_create_autocmd("BufWinEnter", {
    group = vim.api.nvim_create_augroup("nickkadutskyi-netrw-close", { clear = true }),
    callback = function()
        local filetype = vim.fn.getbufvar(vim.fn.winbufnr(vim.fn.winnr()), "&filetype")
        if filetype ~= "netrw" then
            close_netrw()
        end
    end,
})

-- Commented out as in original:
-- vim.api.nvim_create_autocmd({'FileType', 'BufLeave'}, {
--     pattern = 'netrw',
--     callback = function()
--         if vim.bo.filetype == 'netrw' then
--             close_netrw()
--         end
--     end
-- })

-- Lazy.nvim module
return {}

local function get_term_index(current_id, terms)
    local idx
    for i, v in ipairs(terms) do
        if v.id == current_id then
            idx = i
        end
    end
    return idx
end

local function go_prev_term(id)
    local current_id = id or vim.b.toggle_number
    if current_id == nil then
        return
    end

    local terms = require("toggleterm.terminal").get_all(true)
    local prev_index

    local index = get_term_index(current_id, terms)
    if index > 1 then
        prev_index = index - 1
    else
        prev_index = #terms
    end
    require("toggleterm").toggle(terms[index].id)
    require("toggleterm").toggle(terms[prev_index].id)
end

local function go_next_term(id)
    local current_id = id or vim.b.toggle_number
    if current_id == nil then
        return
    end

    local terms = require("toggleterm.terminal").get_all(true)
    local next_index

    local index = get_term_index(current_id, terms)
    if index == #terms then
        next_index = 1
    else
        next_index = index + 1
    end
    require("toggleterm").toggle(terms[index].id)
    require("toggleterm").toggle(terms[next_index].id)
end
local function toggle_terminal()
    local ui = require("toggleterm.ui")
    local terms = require("toggleterm.terminal")
    local has_open, windows = ui.find_open_windows()

    if has_open then
        local focused = false
        -- for _, win in ipairs(windows) do
        --     if win.window == winid then
        --         focused = true
        --     end
        -- end
        if windows[1].window == vim.api.nvim_get_current_win() then
            ui.close_and_save_terminal_view(windows)
        else
            vim.api.nvim_set_current_win(windows[1].window)
            vim.cmd.startinsert()
        end
    else
        if not ui.open_terminal_view() then
            local term_id = terms.get_toggled_id()
            terms.get_or_create_term(term_id):open()
        end
    end
end

return {
    {
        -- Terminal in floating window
        -- TODO add ability to open multiple terminals and cylce through them
        "akinsho/toggleterm.nvim",
        version = "*",
        config = function()
            local toggleterm = require("toggleterm")
            local terms = require("toggleterm.terminal")

            toggleterm.setup({
                start_in_insert = false,
                -- requires delay to start in insert mode
                on_open = function(t)
                    vim.fn.timer_start(1, function()
                        vim.cmd("startinsert!")
                    end)
                end,
                -- reuqire toggling again after exiting to get back to term
                on_exit = function(t)
                    vim.fn.timer_start(1, function()
                        if #require("toggleterm.terminal").get_all(true) ~= 0 then
                            toggle_terminal()
                        end
                    end)
                end,
            })

            for lhs, mode in pairs({
                ["<leader>at"] = { "n" },
                ["<A-F12>"] = { "n", "t" },
                ["<F60>"] = { "n", "t" },
            }) do
                vim.keymap.set(mode, lhs, function()
                    vim.cmd("CloseNetrw")
                    vim.cmd("CloseNetrw")
                    toggle_terminal()
                    -- toggleterm.toggle()
                end, { noremap = true, desc = "[a]ctivate [t]erminal tool window (Terminal)" })
            end

            vim.api.nvim_create_autocmd("TermOpen", {
                group = vim.api.nvim_create_augroup("nickkadutskyi-term-open", { clear = true }),
                pattern = { "term://*toggleterm#*" },
                callback = function(event)
                    vim.keymap.set({ "t" }, "<Esc>", "<C-\\><C-O><C-W><C-W><Esc>", {
                        desc = "Term: Leave terminal",
                        buffer = event.buf,
                    })

                    vim.keymap.set({ "n" }, "<Esc>", "<C-W><C-W>", {
                        desc = "Term: Leave terminal",
                        buffer = event.buf,
                    })
                    -- Create new terminal tab
                    for lhs, mode in pairs({
                        ["<A-t>"] = { "n", "t" },
                        ["†"] = { "n", "t" },
                    }) do
                        vim.keymap.set(mode, lhs, function()
                            toggleterm.toggle(vim.b.toggle_number)
                            toggleterm.toggle(terms.get_or_create_term().id)
                        end, {
                            desc = "Create new terminal tab",
                            buffer = event.buf,
                        })
                    end

                    vim.keymap.set({ "t", "n" }, "<C-Right>", function()
                        go_next_term()
                    end, {
                        desc = "Go to next terminal",
                        buffer = event.buf,
                    })

                    vim.keymap.set({ "t", "n" }, "<C-Left>", function()
                        go_prev_term()
                    end, {
                        desc = "Go to previous terminal",
                        buffer = event.buf,
                    })

                    for lhs, mode in pairs({
                        ["<A-W>"] = { "n", "t" },
                        ["∑"] = { "n", "t" },
                    }) do
                        vim.keymap.set(mode, lhs, function()
                            local to_close = vim.b.toggle_number
                            go_prev_term()
                            terms.get(to_close):shutdown()
                        end, {
                            desc = "Close terminal",
                            buffer = event.buf,
                        })
                    end
                end,
            })
        end,
    },
}

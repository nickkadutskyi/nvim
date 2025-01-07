local toggleterm_pattern = { "term://*#toggleterm#*", "term://*::toggleterm::*" }
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

    local terms = require("toggleterm.terminal").get_all()
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

    local terms = require("toggleterm.terminal").get_all()
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

---@param current_term ?Terminal
local function get_term_to_switch_after_exit(current_term)
    if current_term == nil then
        return nil
    end
    local all = require("toggleterm.terminal").get_all()
    for index, term in ipairs(all) do
        if term.id == current_term.id then
            if index ~= #all then
                return all[index + 1]
            elseif #all == index and #all > 1 then
                return all[index - 1]
            end
        elseif term.id > current_term.id then
            return term
        elseif #all == index then
            return term
        end
    end
    return nil
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
        local current_win = vim.api.nvim_get_current_win()
        if windows[1].window == current_win then
            ui.close_and_save_terminal_view(windows)
        else
            vim.api.nvim_set_current_win(windows[1].window)
            vim.g.term_activated_from = current_win
        end
    else
        local current_win = vim.api.nvim_get_current_win()
        vim.g.term_activated_from = current_win
        if not ui.open_terminal_view() then
            local term_id = terms.get_toggled_id()
            terms.get_or_create_term(term_id):open()
        end
    end
end

return {
    {
        -- Terminal in floating window
        "akinsho/toggleterm.nvim",
        version = "*",
        config = function()
            local toggleterm = require("toggleterm")
            local terms = require("toggleterm.terminal")
            local ui = require("toggleterm.ui")

            toggleterm.setup({
                start_in_insert = true,
                persist_mode = false,
                on_open = function(_)
                    vim.fn.timer_start(1, function()
                        vim.cmd("startinsert!")
                    end)
                end,
                ---@param t Terminal
                on_exit = function(t)
                    -- Mimics behavior in Intellij terminal
                    if t.close_on_exit == true then
                        t.close_on_exit = false
                        local switch_term = get_term_to_switch_after_exit(t)
                        if t:is_open() == true and t:is_focused() == false then
                            if switch_term ~= nil then
                                local mode = vim.api.nvim_get_mode()
                                ui.close(t)
                                switch_term:toggle()
                                vim.fn.timer_start(1, function()
                                    ui.goto_previous()
                                    if mode.mode == "n" then
                                        vim.cmd("stopinsert!")
                                    end
                                end)
                            else
                                ui.close(t)
                            end
                        elseif t:is_focused() == true and switch_term ~= nil then
                            ui.close(t)
                            vim.fn.timer_start(1, function()
                                switch_term:toggle()
                            end)
                        else
                            ui.close(t)
                        end
                    end
                end,
                close_on_exit = true,
            })

            for lhs, mode in pairs({
                ["<leader>at"] = { "n" },
                ["<A-F12>"] = { "n", "t" },
                ["<F60>"] = { "n", "t" },
            }) do
                vim.keymap.set(mode, lhs, function()
                    vim.cmd("CloseProjectView")
                    toggle_terminal()
                end, { noremap = true, desc = "Terminal: [a]ctivate [t]erminal tool window." })
            end

            vim.api.nvim_create_autocmd("TermOpen", {
                group = vim.api.nvim_create_augroup("nickkadutskyi-term-open", { clear = true }),
                pattern = toggleterm_pattern,
                callback = function(event)
                    vim.opt_local.conceallevel = 2
                    vim.cmd([[syntax match Conceal /\%u200b/ conceal]])
                    -- Keymap
                    -- Hide active terminal tool window
                    vim.keymap.set({ "t", "n" }, "<A-Esc>", toggle_terminal, {
                        desc = "Term: Hide terminal",
                        buffer = event.buf,
                    })
                    -- Leave terminal mode
                    vim.keymap.set({ "t" }, "<Esc>", "<C-\\><C-N>", {
                        desc = "Term: Leave terminal mode",
                        buffer = event.buf,
                    })
                    -- Leave terminal to previous window
                    vim.keymap.set({ "n" }, "<Esc>", function()
                        if vim.g.term_activated_from ~= nil then
                            vim.api.nvim_set_current_win(vim.g.term_activated_from)
                        else
                            -- Simply go to another window
                            vim.cmd("wincmd w")
                        end
                    end, {
                        desc = "Term: Leave terminal to previous window",
                        buffer = event.buf,
                    })
                    -- Create new terminal tab
                    for lhs, mode in pairs({
                        ["<A-t>"] = { "n", "t" },
                        ["†"] = { "n", "t" },
                    }) do
                        vim.keymap.set(mode, lhs, function()
                            terms.get(terms.get_focused_id()):close()
                            terms.get_or_create_term():toggle()
                        end, {
                            desc = "Term: Create new terminal tab",
                            buffer = event.buf,
                        })
                    end

                    -- Go to next terminal
                    vim.keymap.set({ "t", "n" }, "<C-Right>", function()
                        go_next_term()
                    end, {
                        desc = "Term: Go to next terminal",
                        buffer = event.buf,
                    })

                    -- Go to previous terminal
                    vim.keymap.set({ "t", "n" }, "<C-Left>", function()
                        go_prev_term()
                    end, {
                        desc = "Term: Go to previous terminal",
                        buffer = event.buf,
                    })

                    -- Close terminal
                    for lhs, mode in pairs({
                        ["<A-w>"] = { "n", "t" },
                        -- ["∑"] = { "n", "t" },
                    }) do
                        vim.keymap.set(mode, lhs, function()
                            local to_close = terms.get(terms.get_focused_id())
                            local to_switch = get_term_to_switch_after_exit(to_close)
                            if to_close ~= nil then
                                to_close.on_exit = function()
                                    vim.fn.timer_start(1, function()
                                        if to_switch ~= nil then
                                            toggleterm.toggle(to_switch.id)
                                        end
                                    end)
                                end
                                terms.get(to_close.id):shutdown()
                            end
                        end, {
                            desc = "Term: Close terminal",
                            buffer = event.buf,
                        })
                    end
                end,
            })
        end,
    },
}

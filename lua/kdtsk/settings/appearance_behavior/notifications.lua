---TODO: move to snacks.nvim and style snacks.nvim notify
---@type LazySpec
return {
    {
        "nickkadutskyi/snacks.nvim",
        priority = 1000,
        enabled = true,
        lazy = false,
        ---@type snacks.Config
        opts = {
            styles = {
                notification = {
                    wo = {
                        wrap = true,
                    },
                },
            },
            notifier = {
                timeout = 5000,
                width = { min = 50, max = 50 },
                margin = { top = 0, right = 1, bottom = 0, left = 3 },
                style = function(buf, notif, ctx)
                    vim.api.nvim_buf_set_lines(buf, 0, 0, false, { "", "" })
                    vim.api.nvim_buf_set_lines(
                        buf,
                        1,
                        -1,
                        false,
                        vim.tbl_map(function(str)
                            return " " .. str
                        end, vim.split(notif.msg, "\n"))
                    )
                    vim.api.nvim_buf_set_extmark(buf, ctx.ns, 0, 0, {
                        virt_text = {
                            { " " },
                            { notif.icon, ctx.hl.icon },
                            { " " },
                            { notif.title or "", ctx.hl.title },
                        },
                        virt_text_win_col = 0,
                        priority = 10,
                    })
                end,
                top_down = false,
                icons = {
                    error = " ",
                    warn = " ",
                    info = " ",
                    debug = " ",
                    trace = " ",
                },
            },
        },
    },
    {
        -- Notifications
        "rcarriga/nvim-notify",
        enabled = false,
        -- pinned it due to bad update in next commit
        commit = "ab98fec",
        opts = {
            minimum_width = 50,
            max_width = 50,
            render = "wrapped-compact",
            icons = {
                WARN = "",
            },
            top_down = false,
            stages = "static",
        },
        init = function()
            vim.notify = function(message, level, opts)
                opts = opts or {}
                if opts.title == nil then
                    opts.title = "Notification"
                end
                return require("notify")(message, level, opts)
            end

            -- table from lsp severity to vim severity.
            local severity = {
                "error",
                "warn",
                "info",
                "info", -- map both hint and info to info?
            }
            vim.lsp.handlers["window/showMessage"] = function(err, method, params)
                local client = vim.lsp.get_client_by_id(params.client_id) or {}
                vim.notify(method.message, severity[method.type], { title = "LSP: " .. (client.name or "Unknown") })
            end

            -- Fixes overlap with statusline
            -- See https://github.com/rcarriga/nvim-notify/issues/189#issuecomment-2225599658
            local override = function(direction)
                local top = 0
                local bottom = vim.opt.lines:get()
                    - (vim.opt.cmdheight:get() + (vim.opt.laststatus:get() > 0 and 1 or 0))
                if vim.wo.winbar then
                    bottom = bottom - 2
                end
                local left = 1
                local right = vim.opt.columns:get()
                if direction == "top_down" then
                    return top, bottom
                elseif direction == "bottom_up" then
                    return bottom, top
                elseif direction == "left_right" then
                    return left, right
                elseif direction == "right_left" then
                    return right, left
                end
                error(string.format("Invalid direction: %s", direction))
            end
            local util = require("notify.stages.util")
            util.get_slot_range = override
        end,
    },
}

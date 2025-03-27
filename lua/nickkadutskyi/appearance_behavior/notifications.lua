return {
    {
        -- Notifications
        "rcarriga/nvim-notify",
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

            -- Utility functions shared between progress reports for LSP and DAP

            local client_notifs = {}

            local function get_notif_data(client_id, token)
                if not client_notifs[client_id] then
                    client_notifs[client_id] = {}
                end

                if not client_notifs[client_id][token] then
                    client_notifs[client_id][token] = {}
                end

                return client_notifs[client_id][token]
            end

            local spinner_frames = { "⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷" }

            local function update_spinner(client_id, token)
                local notif_data = get_notif_data(client_id, token)

                if notif_data.spinner then
                    local new_spinner = (notif_data.spinner + 1) % #spinner_frames
                    notif_data.spinner = new_spinner

                    notif_data.notification = vim.notify(nil, nil, {
                        hide_from_history = true,
                        icon = spinner_frames[new_spinner],
                        replace = notif_data.notification,
                    })

                    vim.defer_fn(function()
                        update_spinner(client_id, token)
                    end, 100)
                end
            end

            local function format_title(title, client_name)
                return client_name .. (#title > 0 and ": " .. title or "")
            end

            local function format_message(message, percentage)
                return (percentage and percentage .. "%\t" or "") .. (message or "")
            end

            -- LSP integration
            -- Make sure to also have the snippet with the common helper functions in your config!

            vim.lsp.handlers["$/progress"] = function(_, result, ctx)
                local client_id = ctx.client_id

                local val = result.value

                if not val.kind then
                    return
                end

                local notif_data = get_notif_data(client_id, result.token)

                if val.kind == "begin" then
                    local message = format_message(val.message, val.percentage)

                    notif_data.notification = vim.notify(message, "info", {
                        title = format_title(val.title, vim.lsp.get_client_by_id(client_id).name),
                        icon = spinner_frames[1],
                        timeout = false,
                        hide_from_history = false,
                    })

                    notif_data.spinner = 1
                    update_spinner(client_id, result.token)
                elseif val.kind == "report" and notif_data then
                    notif_data.notification = vim.notify(format_message(val.message, val.percentage), "info", {
                        replace = notif_data.notification,
                        hide_from_history = false,
                    })
                elseif val.kind == "end" and notif_data then
                    notif_data.notification =
                        vim.notify(val.message and format_message(val.message) or "Complete", "info", {
                            icon = "",
                            replace = notif_data.notification,
                            timeout = 3000,
                        })

                    notif_data.spinner = nil
                end
            end
        end,
    },
}

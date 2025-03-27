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
        end,
    },
}

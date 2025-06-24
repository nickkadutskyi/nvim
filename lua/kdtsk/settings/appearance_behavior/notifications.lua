---TODO: move to snacks.nvim and style snacks.nvim notify
---@type LazySpec
return {
    {
        "nickkadutskyi/snacks.nvim",
        priority = 1000,
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
                        -- pads each row to align with icon
                        vim.tbl_map(function(str)
                            return "   " .. str
                        end, vim.split(notif.msg, "\n"))
                    )
                    vim.api.nvim_buf_set_extmark(buf, ctx.ns, 0, 0, {
                        virt_text = {
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
}

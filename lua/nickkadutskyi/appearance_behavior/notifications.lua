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
            stages = "fade_in_slide_out",
        },
        init = function()
            vim.notify = require("notify")
        end,
    },
}

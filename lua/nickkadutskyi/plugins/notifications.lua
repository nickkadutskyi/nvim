-- TODO add ability to move fidget on top of notifications in the bottom right
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
            vim.notify = require("notify")
        end,
    },
    {
        -- Progress (LSP)
        "j-hui/fidget.nvim",
        opts = {
            notification = {
                window = {
                    x_padding = 2,
                },
            },
        },
    },
}

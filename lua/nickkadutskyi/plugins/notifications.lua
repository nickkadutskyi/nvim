return {
    "rcarriga/nvim-notify",
    opts = {
        minimum_width = 40,
        max_width = 40,
        render = "wrapped-compact",
        icons = {
            WARN = "",
        },
    },
    init = function()
       vim.notify = require("notify")
    end,
}

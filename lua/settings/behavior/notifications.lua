local spec_builder = require("ide.spec.builder")

spec_builder.add({
    "nvim-notify",
    opts = {
        minimum_width = 50,
        max_width = 50,
        render = "wrapped-compact",
        icons = { WARN = "" },
        top_down = false,
        -- Using custom stages to provide my own border and padding
        stages = {
            function(state)
                local next_height = state.message.height + 2
                local next_row =
                    require("notify.stages.util").available_slot(state.open_windows, next_height, "bottom_up")
                if not next_row then
                    return nil
                end
                return {
                    relative = "editor",
                    anchor = "NE",
                    width = state.message.width,
                    height = state.message.height,
                    col = vim.opt.columns:get() - 1,
                    row = next_row - 1,
                    border = require("jb.borders").borders.notification,
                    style = "minimal",
                }
            end,
            function()
                return {
                    col = vim.opt.columns:get() - 1,
                    time = true,
                }
            end,
        },
    },
})

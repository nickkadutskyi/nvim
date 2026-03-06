return {
    { -- Status bar controller in the top right corner
        "b0o/incline.nvim",
        config = function()
            require("incline").setup({
                render = function(props)
                    return {
                        { Utils.incline.component_diagnostics(props) },
                    }
                end,
            })
        end,
        -- Optional: Lazy load Incline
        event = "VeryLazy",
    },
}

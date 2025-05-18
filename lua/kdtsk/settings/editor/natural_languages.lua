---TODO: consider https://github.com/ribru17/blink-cmp-spell source
---@type LazySpec
return {
    { -- Provides spelling suggestions popup instead of the default list
        "which-key.nvim",
        event = "VeryLazy",
        opts = {
            spelling = {
                -- enabling this will show WhichKey when pressing z= to select spelling suggestions
                enabled = true,
                -- how many suggestions should be shown in the list?
                suggestions = 10,
            },
        },
    },
}

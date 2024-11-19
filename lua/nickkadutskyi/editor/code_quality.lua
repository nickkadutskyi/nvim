return {
    {
        -- Code Quality
        "mfussenegger/nvim-lint",
        event = { "BufReadPre", "BufNewFile" },
        -- Keep empty config() to prevent auto-setup
        config = function(plugin, opts) end,
    },
}

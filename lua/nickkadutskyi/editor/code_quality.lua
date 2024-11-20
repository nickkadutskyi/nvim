return {
    {
        -- Code Quality
        "mfussenegger/nvim-lint",
        event = { "BufReadPre", "BufNewFile" },
        -- Keep empty config() to prevent auto-setup
        config = function() end,
    },
    {
        "rshkarin/mason-nvim-lint",
        dependencies = { "mfussenegger/nvim-lint", "williamboman/mason.nvim" },
        -- insure_installed is merged from nickkadutskyi.languages_frameworks
        opts = { automatic_installation = false },
        config = true,
    },
}

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
        -- ensure_installed is merged from nickkadutskyi.languages_frameworks
        opts = { automatic_installation = false },
        config = function(_, opts)
            vim.api.nvim_create_user_command("CodeLintersInstall", function()
                require("mason-nvim-lint").setup(opts)
            end, {})
        end,
    },
}

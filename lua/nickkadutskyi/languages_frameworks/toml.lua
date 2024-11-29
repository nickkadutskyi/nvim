---Config

---@type LazySpec
return {
    { -- Code Style
        "stevearc/conform.nvim",
        opts = {
            formatters_by_ft = {
                toml = { "taplo" },
            },
        },
    }
}

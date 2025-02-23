---@type LazySpec
return {
    { -- Code Style
        "conform.nvim",
        opts = {
            formatters_by_ft = {
                xml = { "xmlstarlet" },
            },
        },
    },
}

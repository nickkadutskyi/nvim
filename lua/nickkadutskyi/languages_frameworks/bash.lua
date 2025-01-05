return {
    {
        "nvim-lspconfig",
        opts = {
            servers = {
                ["bashls"] = {
                    filetypes = { "sh", "zsh" },
                },
            },
        },
    },
}

---@type LazySpec
return {

    { -- Language Servers
        "nvim-lspconfig",
        opts = {
            servers = {
                ["emmet_ls"] = {
                    filetypes = {
                        "html",
                        "css",
                        "php",
                        "sass",
                        "scss",
                        "vue",
                        "javascript",
                    },
                },
            },
        },
    },
}

---@type LazySpec
return {

    { -- Language Servers
        "nvim-lspconfig",
        opts = {
            ---@type table<string,vim.lsp.Config>
            servers = {
                ["emmet_ls"] = {
                    enabled = true,
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

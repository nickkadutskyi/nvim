return {
    {
        -- AI Assistant
        "supermaven-inc/supermaven-nvim",
        opts = { log_level = "error" },
    },
    {
        -- Autocompletion
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            "neovim/nvim-lspconfig",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-nvim-lua",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/cmp-nvim-lsp-signature-help",
            "hrsh7th/cmp-nvim-lsp-document-symbol",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
            "folke/lazydev.nvim",
            {
                "fbuchlak/cmp-symfony-router",
                dependencies = { "nvim-lua/plenary.nvim" },
            },
        },
        config = function()
            local luasnip = require("luasnip")
            local cmp = require("cmp")
            local cmp_select = { behavior = cmp.SelectBehavior.Select }
            -- local cmp_select = { behavior = cmp.ConfirmBehavior.Insert }
            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body) -- For `luasnip` users.
                    end,
                },
                completion = {
                    completeopt = "menu,menuone,noinsert",
                },
                formatting = {
                    expandable_indicator = true,
                    fields = { "abbr", "kind", "menu" },
                    format = function(entry, item)
                        local n = entry.source.name
                        local label = ""

                        if n == "nvim_lsp" then
                            label = "[LSP]"
                        elseif n == "nvim_lua" then
                            label = "[nvim]"
                        else
                            label = string.format("[%s]", n)
                        end

                        if item.menu ~= nil then
                            item.menu = string.format("%s %s", label, item.menu)
                        else
                            item.menu = label
                        end
                        return item
                    end,
                },
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
                    ["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
                    ["<C-y>"] = cmp.mapping.confirm({ select = true }),
                    ["<C-e>"] = cmp.mapping.abort(),
                    ["<C-a>"] = cmp.mapping.complete(),
                    ["<C-b>"] = cmp.mapping.scroll_docs(-5),
                    ["<C-f>"] = cmp.mapping.scroll_docs(5),
                    -- Use <Tab> only within snippets because it interferes with ai assistant
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "nvim_lsp_signature_help" },
                    { name = "nvim_lsp_document_symbol" },
                    { name = "nvim_lua" },
                    { name = "luasnip" }, -- For luasnip users.
                    { name = "path" },
                    { name = "lazydev" },
                    {
                        name = "symfony_router",
                        -- these options are default, you don't need to include them in setup
                        option = {
                            console_command = { "php", "bin/console" }, -- see Configuration section
                            cwd = nil, -- string|nil Defaults to vim.loop.cwd()
                            cwd_files = { "composer.json", "bin/console" }, -- all these files must exist in cwd to trigger completion
                            filetypes = { "php", "twig" },
                        },
                    },
                }, {
                    { name = "buffer" },
                    { name = "supermaven" }, -- disabled to keep it as ghost text only
                }),
                experimental = {
                    ghost_text = false, -- this feature conflict with ai assistant inline preview
                },
            })

            require("cmp").setup.cmdline("/", {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({
                    { name = "nvim_lsp_document_symbol" },
                }, {
                    { name = "buffer" },
                }),
            })

            cmp.setup.cmdline(":", {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({
                    { name = "path" },
                }, {
                    {
                        name = "cmdline",
                        option = {
                            ignore_cmds = { "Man", "!" },
                        },
                    },
                }),
            })
        end,
    },
}

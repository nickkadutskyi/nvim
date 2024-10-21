return {
    {
        -- AI Assistant
        "supermaven-inc/supermaven-nvim",
        opts = { log_level = "error" },
    },
    {
        -- Autocompletion
        "hrsh7th/nvim-cmp",
        dependencies = {
            "neovim/nvim-lspconfig",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
            "folke/lazydev.nvim",
            -- "williamboman/mason-lspconfig.nvim",
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
                    { name = "luasnip" }, -- For luasnip users.
                }, {
                    { name = "buffer" },
                    { name = "lazydev", group_index = 0 },
                }),
                experimental = {
                    ghost_text = false, -- this feature conflict with ai assistant inline preview
                },
            })
        end,
    },
}

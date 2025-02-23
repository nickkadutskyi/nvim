return {
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
            }, -- Symfony router in completion
            "zbirenbaum/copilot-cmp", -- copilot suggestions
        },
        config = function()
            local luasnip = require("luasnip")
            local cmp = require("cmp")
            local cmp_select = { behavior = cmp.SelectBehavior.Select }
            cmp.setup({
                view = {
                    entries = {
                        -- name = "native",
                        name = "custom",
                        -- selection_order = "top_down",
                        follow_cursor = false,
                    },
                    docs = {
                        auto_open = true,
                    },
                },
                preselect = cmp.PreselectMode.Item,
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body) -- For `luasnip` users.
                    end,
                },
                completion = {
                    completeopt = "menu,menuone,noinsert,popup",
                },
                formatting = {
                    expandable_indicator = true,
                    fields = { "abbr", "kind", "menu" },
                    format = function(entry, item)
                        local n = entry.source.name
                        local label = ""

                        if n == "nvim_lsp" then
                            label = "[lsp]"
                        elseif n == "nvim_lua" then
                            label = "[nvm]"
                        elseif n == "copilot" then
                            label = "[llm]"
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
                    completion = cmp.config.window.bordered({
                        winhighlight = "Normal:Pmenu,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
                    }),
                    documentation = cmp.config.window.bordered({
                        winhighlight = "Normal:Pmenu,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
                    }),
                },
                mapping = cmp.mapping.preset.insert({
                    ["<Down>"] = function(fallback)
                        if cmp.visible() then
                            cmp.close()
                        end
                        fallback()
                    end,
                    ["<Up>"] = function(fallback)
                        if cmp.visible() then
                            cmp.close()
                        end
                        fallback()
                    end,
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
                -- TODO Restructure this config to make it composable from different files
                sources = cmp.config.sources(
                    -- Group 0
                    {
                        -- Prioritizes this over LuaLS from nvim_lsp
                        { name = "lazydev", priority = 500 },
                    },
                    -- Group 1
                    {
                        { name = "nvim_lsp", priority = 1000 },
                        ---Shows signauter documentation when entering `(` after a function
                        { name = "nvim_lsp_signature_help", priority = 1000 },
                        ---Snippets
                        { name = "luasnip", priority = 1000 }, -- For luasnip users.
                        { name = "nvim_lua", priority = 750 },
                        { name = "path", priority = 500 },
                        -- TODO move this to Symfony specific file
                        {
                            name = "symfony_router",
                            -- these options are default, you don't need to include them in setup
                            option = {
                                -- see Configuration section
                                console_command = { "php", "bin/console" },
                                -- string|nil Defaults to vim.loop.cwd()
                                cwd = nil,
                                -- all these files must exist in cwd to trigger completion
                                cwd_files = { "composer.json", "bin/console" },
                                filetypes = { "php", "twig" },
                            },
                            priority = 500,
                        },
                        { name = "copilot", priority = 100 },
                        -- { name = "supermaven" }, -- disabled to keep it as ghost text only
                    },
                    -- Group 2
                    {
                        { name = "buffer" },
                    }
                ),
                experimental = {
                    ghost_text = false, -- this feature conflict with ai assistant inline preview
                },
                -- sorting = {
                --     priority_weight = 2,
                --     comparators = {
                --
                --         -- Below is the default comparitor list and order for nvim-cmp
                --         cmp.config.compare.offset,
                --         -- cmp.config.compare.scopes, --this is commented in nvim-cmp too
                --         cmp.config.compare.exact,
                --         cmp.config.compare.score,
                --         cmp.config.compare.recently_used,
                --         require("copilot_cmp.comparators").prioritize,
                --         cmp.config.compare.locality,
                --         cmp.config.compare.kind,
                --         -- cmp.config.compare.sort_text,
                --         cmp.config.compare.length,
                --         cmp.config.compare.order,
                --     },
                -- },
            })

            cmp.setup.cmdline("/", {
                preselect = cmp.PreselectMode.None,
                completion = {
                    completeopt = "menu,menuone,noselect",
                },
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources(
                    -- Group 1
                    ---@type cmp.SourceConfig[]
                    {
                        ---Completion for LSP symbols during search
                        { name = "nvim_lsp_document_symbol", max_item_count = 10 },
                    },
                    -- Group 2
                    ---@type cmp.SourceConfig[]
                    {
                        { name = "buffer", max_item_count = 10 },
                    }
                ),
            })

            cmp.setup.cmdline(":", {
                preselect = cmp.PreselectMode.None,
                completion = {
                    completeopt = "menu,menuone,noselect",
                },
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources(
                    -- Group 1
                    ---@type cmp.SourceConfig[]
                    {
                        { name = "path", max_item_count = 10 },
                        {
                            name = "cmdline",
                            option = {
                                ignore_cmds = { "Man", "!" },
                            },
                            max_item_count = 10,
                        },
                    },
                    -- Group 2
                    ---@type cmp.SourceConfig[]
                    {}
                ),
            })
        end,
    },
}

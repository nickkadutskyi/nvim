return {
    {
        "saghen/blink.cmp",
        -- optional: provides snippets for the snippet source
        dependencies = {
            "rafamadriz/friendly-snippets",
            "folke/lazydev.nvim",
            "mikavilpas/blink-ripgrep.nvim",
            "Kaiser-Yang/blink-cmp-avante",
        },

        -- use a release tag to download pre-built binaries
        version = "1.*",
        -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
        -- build = 'cargo build --release',
        -- If you use nix, you can build from source using latest nightly rust with:
        build = "nix run .#build-plugin",

        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        opts = {
            -- All presets have the following mappings:
            -- C-space: Open menu or open docs if already open
            -- C-n/C-p or Up/Down: Select next/previous item
            -- C-e: Hide menu
            -- C-k: Toggle signature help (if signature.enabled = true)
            -- See :h blink-cmp-config-keymap for defining your own keymap
            keymap = { preset = "default" },

            completion = {
                documentation = {
                    -- Shows documentation pop-up automatically when available
                    auto_show = true,
                    window = { border = "rounded" },
                },
                menu = {
                    scrollbar = false,
                    border = "rounded",
                    auto_show = true,
                    -- draw = {
                    --     columns = {
                    --         { "label", "label_description", gap = 1 },
                    --         { "kind_icon", "kind" },
                    --     },
                    -- },
                },
            },

            -- Default list of enabled providers defined so that you can extend it
            -- elsewhere in your config, without redefining it, due to `opts_extend`
            sources = {
                default = { "avante", "lsp", "path", "snippets", "buffer", "ripgrep" },
                per_filetype = {
                    lua = { inherit_defaults = true, "lazydev" },
                },
                providers = {
                    avante = {
                        module = "blink-cmp-avante",
                        name = "Avante",
                        opts = {
                            -- options for blink-cmp-avante
                        },
                    },
                    lazydev = {
                        name = "LazyDev",
                        module = "lazydev.integrations.blink",
                        score_offset = 100,
                    },
                    ripgrep = {
                        module = "blink-ripgrep",
                        name = "Ripgrep",
                        ---@module "blink-ripgrep"
                        ---@type blink-ripgrep.Options
                        opts = {
                            prefix_min_len = 3,
                            context_size = 5,
                            max_filesize = "1M",
                            project_root_marker = ".git",
                            project_root_fallback = true,
                            search_casing = "--ignore-case",
                            additional_rg_options = {},
                            fallback_to_regex_highlighting = true,
                            ignore_paths = {},
                            additional_paths = {},
                            toggles = {
                                -- The keymap to toggle the plugin on and off from blink
                                -- completion results. Example: "<leader>tg"
                                on_off = nil,
                            },
                            future_features = {
                                backend = {
                                    -- The backend to use for searching. Defaults to "ripgrep".
                                    -- Available options:
                                    -- - "ripgrep", always use ripgrep
                                    -- - "gitgrep", always use git grep
                                    -- - "gitgrep-or-ripgrep", use git grep if possible, otherwise
                                    --   ripgrep
                                    use = "ripgrep",
                                },
                            },
                            debug = false,
                        },
                    },
                },
            },
            snippets = { preset = "default" },

            -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
            -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
            -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
            --
            -- See the fuzzy documentation for more information
            fuzzy = { implementation = "prefer_rust_with_warning" },
            appearance = {
                highlight_ns = vim.api.nvim_create_namespace("blink_cmp"),
                -- Sets the fallback highlight groups to nvim-cmp's highlight groups
                -- Useful for when your theme doesn't support blink.cmp
                -- Will be removed in a future release
                use_nvim_cmp_as_default = true,
                -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
                -- Adjusts spacing to ensure icons are aligned
                nerd_font_variant = "mono",
                kind_icons = {
                    Text = "",
                    Method = "󰰑",
                    Function = "󰯼",
                    Constructor = "󰰏",

                    Field = "󰯼",
                    Variable = "󰰬",
                    Property = "󰰚",

                    Class = "󰯳",
                    Interface = "󰰅",
                    Struct = "󰰡",
                    Module = "󱓼",

                    Unit = "󰪚",
                    Value = "󰰪",
                    Enum = "󰯹",
                    EnumMember = "󰯱",

                    Keyword = "",
                    Constant = "󰯱",

                    Snippet = "󰴹",
                    Color = "",
                    File = "",
                    Reference = "󰬳",
                    Folder = "",
                    Event = "󱐋",
                    Operator = "󱖦",
                    TypeParameter = "󰰦",
                },
            },
        },
        opts_extend = { "sources.default" },
    },
    {
        -- Autocompletion
        "hrsh7th/nvim-cmp",
        enabled = false,
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
                        -- { name = "copilot", priority = 100 },
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

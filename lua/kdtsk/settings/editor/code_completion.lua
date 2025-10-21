---@type LazySpec[]
return {
    {
        "saghen/blink.cmp",
        event = "InsertEnter",
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
        -- build = "nix run .#build-plugin",

        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        opts = {
            -- All presets have the following mappings:
            -- C-space: Open menu or open docs if already open
            -- C-n/C-p or Up/Down: Select next/previous item
            -- C-e: Hide menu
            -- C-k: Toggle signature help (if signature.enabled = true)
            -- See :h blink-cmp-config-keymap for defining your own keymap
            keymap = {
                preset = "default",
                ["<C-a>"] = { "show", "show_documentation", "hide_documentation" },
            },

            completion = {
                documentation = {
                    -- Shows documentation pop-up automatically when available
                    auto_show = true,
                    window = { border = "rounded", scrollbar = false, max_width = 100, },
                },
                menu = {
                    scrollbar = false,
                    border = "rounded",
                    auto_show = true,
                    draw = {
                        columns = {
                            { "kind_icon" },
                            { "label", "label_description", gap = 1 },
                        },
                    },
                },
            },

            -- Default list of enabled providers defined so that you can extend it
            -- elsewhere in your config, without redefining it, due to `opts_extend`
            sources = {
                default = { "lsp", "path", "snippets", "buffer", "avante" },
                per_filetype = {
                    lua = { inherit_defaults = true, "lazydev" },
                },
                providers = {
                    lsp = { fallbacks = {} },
                    avante = {
                        module = "blink-cmp-avante",
                        name = "Avante",
                        opts = {
                            kind_icons = {
                                Avante = "󰘳",
                                AvanteCmd = "󰘳",
                                AvanteMention = "",
                            },
                            command = {
                                get_kind_name = function(_)
                                    return "AvanteCmd"
                                end,
                            },
                            mention = {
                                get_kind_name = function(_)
                                    return "AvanteMention"
                                end,
                            },
                            avante = {},
                        },
                    },
                    lazydev = {
                        name = "LazyDev",
                        module = "lazydev.integrations.blink",
                        score_offset = 100,
                    },

                    -- Disabled because slow in large projects
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
                -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
                -- Adjusts spacing to ensure icons are aligned
                nerd_font_variant = "mono",
            },
        },
        -- Tells Lazy.nvim to merge this path as a list
        opts_extend = { "sources.default" },
        config = function(_, opts)
            opts.appearance.kind_icons = Utils.icons.kind
            require("blink.cmp").setup(opts)
        end,
    },
}

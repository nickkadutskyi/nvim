---@type LazySpec
return {
    { -- AI Suggestions
        "github/copilot.vim",
        dependencies = { "folke/which-key.nvim" },
        cond = function()
            return Utils.is_path_in_paths(vim.fn.getcwd(), {
                "~/Documents",
                "~/.config/nvim",
                "~/.config/nixos-config",
            })
        end,
        init = function()
            vim.g.copilot_settings = { selectedCompletionModel = "gpt-41-copilot" }
            vim.g.copilot_integration_id = "vscode-chat"
            vim.g.copilot_lsp_settings = {
                telemetry = {
                    telemetryLevel = "off",
                },
            }
        end,
        config = function()
            -- Keymap
            vim.keymap.set("i", "<A-]>", "<Plug>(copilot-next)", { desc = "AI: Next suggestion" })
            vim.keymap.set("i", "<A-[>", "<Plug>(copilot-previous)", { desc = "AI: Previous suggestion" })
            vim.keymap.set("i", "<A-Tab>", "<Plug>(copilot-accept-word)", {
                desc = "AI: Accept word suggestion (copilot.vim)",
            })
            vim.keymap.set("i", "<S-Tab>", "<Plug>(copilot-accept-line)", {
                desc = "AI: Accept line suggestion (copilot.vim)",
            })
            -- Documents built-in keymap
            require("which-key").add({
                { "<Tab>", desc = "AI: Accept suggestion (copilot.vim)", mode = "i" },
                { "<C-]>", desc = "AI: Dismiss suggestion (copilot.vim)", mode = "i" },
            })
        end,
    },
    {
        "ThePrimeagen/99",
        config = function()
            local _99 = require("99")

            -- For logging that is to a file if you wish to trace through requests
            -- for reporting bugs, i would not rely on this, but instead the provided
            -- logging mechanisms within 99.  This is for more debugging purposes
            local cwd = vim.uv.cwd()
            local basename = vim.fs.basename(cwd)
            _99.setup({
                model = "github-copilot/claude-opus-4.6",
                logger = {
                    level = _99.DEBUG,
                    path = "/tmp/" .. basename .. ".99.debug",
                    print_on_error = true,
                },
                completion = {
                    --- Defaults to .cursor/rules
                    -- I am going to disable these until i understand the
                    -- problem better.  Inside of cursor rules there is also
                    -- application rules, which means i need to apply these
                    -- differently
                    -- cursor_rules = "<custom path to cursor rules>"

                    --- A list of folders where you have your own SKILL.md
                    --- Expected format:
                    --- /path/to/dir/<skill_name>/SKILL.md
                    ---
                    --- Example:
                    --- Input Path:
                    --- "scratch/custom_rules/"
                    ---
                    --- Output Rules:
                    --- {path = "scratch/custom_rules/vim/SKILL.md", name = "vim"},
                    --- ... the other rules in that dir ...
                    ---
                    custom_rules = {
                        "scratch/custom_rules/",
                    },

                    --- What autocomplete do you use.  We currently only
                    --- support cmp right now
                    -- source = "cmp",
                },

                --- WARNING: if you change cwd then this is likely broken
                --- ill likely fix this in a later change
                ---
                --- md_files is a list of files to look for and auto add based on the location
                --- of the originating request.  That means if you are at /foo/bar/baz.lua
                --- the system will automagically look for:
                --- /foo/bar/AGENT.md
                --- /foo/AGENT.md
                --- assuming that /foo is project root (based on cwd)
                md_files = {
                    "AGENT.md",
                },
            })

            -- take extra note that i have visual selection only in v mode
            -- technically whatever your last visual selection is, will be used
            -- so i have this set to visual mode so i dont screw up and use an
            -- old visual selection
            --
            -- likely ill add a mode check and assert on required visual mode
            -- so just prepare for it now
            vim.keymap.set("v", "<leader>9v", function()
                _99.visual()
            end)

            --- if you have a request you dont want to make any changes, just cancel it
            vim.keymap.set("n", "<leader>9x", function()
                _99.stop_all_requests()
            end)

            vim.keymap.set("n", "<leader>9s", function()
                _99.search()
            end)
        end,
    },
}

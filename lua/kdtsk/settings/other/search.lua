local utils = require("kdtsk.utils")
-- Search text in file
-- Case-insensitive searching UNLESS \C or capital in search
vim.opt.ignorecase = true
vim.opt.smartcase = true
-- Incremental search
vim.opt.incsearch = true

local last_go_to_file_time = 0
local last_find_in_path_time = 0
local resume_within_seconds = 60

-- Lazy.nvim modules
return {
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local harpoon = require("harpoon")

            -- REQUIRED
            harpoon:setup({ settings = { save_on_toggle = true } })
            -- REQUIRED

            local harpoon_extensions = require("harpoon.extensions")
            harpoon:extend(harpoon_extensions.builtins.highlight_current_file())
            harpoon:extend(harpoon_extensions.builtins.navigate_with_number())
            harpoon:extend({
                -- Clear the list if the only item in the list is nil
                LIST_CHANGE = function()
                    if harpoon:list():length() == 1 and harpoon:list():get(1) == nil then
                        vim.schedule(function()
                            harpoon:list():clear()
                        end)
                    end
                end,
            })

            vim.keymap.set("n", "<leader>a", function()
                harpoon:list():add()
            end, { desc = "Bookmarks: add current buffers to the list" })
            vim.keymap.set("n", "<C-e>", function()
                harpoon.ui:toggle_quick_menu(harpoon:list(), {
                    title = " Bookmarks ",
                    title_pos = "center",
                    border = require("jb.borders").borders.dialog.default,
                })
            end, { desc = "Bookmarks: toggele list modal" })

            vim.keymap.set("n", "<C-1>", function()
                harpoon:list():select(1)
            end, { desc = "Bookmarks: select 1st item in the list." })
            vim.keymap.set("n", "<C-2>", function()
                harpoon:list():select(2)
            end, { desc = "Bookmarks: select 2nd item in the list." })
            vim.keymap.set("n", "<C-3>", function()
                harpoon:list():select(3)
            end, { desc = "Bookmarks: select 3rd item in the list." })
            vim.keymap.set("n", "<C-4>", function()
                harpoon:list():select(4)
            end, { desc = "Bookmarks: select 4th item in the list." })
            vim.keymap.set("n", "<C-5>", function()
                harpoon:list():select(harpoon:list():length())
            end, { desc = "Bookmarks: select last item in the list." })

            -- Toggle previous & next buffers stored within Harpoon list
            vim.keymap.set("n", "<C-P>", function()
                harpoon:list():prev({ ui_nav_wrap = true })
            end, { desc = "Bookmarks: select next item" })
            vim.keymap.set("n", "<C-N>", function()
                harpoon:list():next({ ui_nav_wrap = true })
            end, { desc = "Bookmarks: select previous item" })
        end,
    },
    {
        "kristoferssolo/lualine-harpoon.nvim",
        dependencies = { { "ThePrimeagen/harpoon", branch = "harpoon2" } },
        opts = {
            -- Configure symbols used in the display
            symbol = {
                -- open = "[",
                open = "",
                -- close = "]",
                close = "",
                separator = "/",
                unknown = "?",
            },
            -- Icon displayed before the harpoon status
            icon = "󰀱",
            -- icon = "",
            -- Show component even when there are no harpoon marks
            show_when_empty = false,
            -- Custom format function (overrides default formatting)
            -- format = function(current, total)
            --     return string.format("Harpoon: %s/%d", current or "?", total)
            -- end,
            -- Cache timeout in milliseconds for performance
            cache_timeout = 100,
        },
    },
    {
        "dmtrKovalenko/fff.nvim",
        -- commit = "03124925701ce1730856bcf9a21f73fa3e55455b",
        build = function()
            -- this will download prebuild binary or try to use existing rustup toolchain to build from source
            -- (if you are using lazy you can use gb for rebuilding a plugin if needed)
            require("fff.download").download_or_build_binary()
        end,
        -- or if you are using nixos
        -- build = "nix run .#release",
        opts = {
            base_path = vim.fn.getcwd(),
            prompt = "   ",
            title = "Files",
            layout = {
                -- height = 25,
                -- width = 95,
                height = function(_terminal_width, terminal_height)
                    return 28 / terminal_height
                end,
                width = function(terminal_width, _terminal_height)
                    return 98 / terminal_width
                end,
                prompt_position = "top", -- or 'top'
                preview_position = "bottom", -- or 'left', 'right', 'top', 'bottom'
                preview_size = 0.5,
            },
            preview = {
                -- enabled = false,
                line_numbers = true,
            },
            hl = {
                border = "FloatBorder",
                normal = "FzfLuaFzfNormal",
                cursor = "FzfLuaFzfCursorLine",
                matched = "FzfLuaFzfMatch",
                title = "FzfLuaTitle",
                prompt = "FzfLuaFzfPrompt",
                active_file = "FzfLuaFzfCursorLine",
                frecency = "Number",
                debug = "Comment",

                combo_header = "Number",
                scrollbar = "FzfLuaFzfScrollbar", -- Highlight for scrollbar thumb (track uses border)
            },
            keymaps = {
                -- goes to the previous query in history
                cycle_previous_query = "<C-h>",
            },
            -- Git integration
            git = {
                status_text_color = true, -- Apply git status colors to filename text (default: false, only sign column)
            },
        },
        keys = {
            {
                "ff", -- try it if you didn't it is a banger keybinding for a picker
                function()
                    require("fff").find_files() -- or find_in_git_root() if you only want git files
                end,
                desc = "Open file picker",
            },
        },
    },
    {
        -- TODO: integrate it properly and see if it's good enough
        -- Provides frecency functionality to fzf-lua
        "elanmed/fzf-lua-frecency.nvim",
        enabled = false,
        opts = {
            -- -- the default actions for FzfLua files, with an additional
            -- -- ["ctrl-x"] action to remove a file's frecency score
            -- actions = actions,
            -- -- FzfLua's default previewer
            -- previewer = previewer,
            file_icons = true,
            color_icons = true,
            git_icons = false,
            fzf_opts = {
                ["--multi"] = true,
                ["--scheme"] = "path",
                ["--no-sort"] = true,
            },
            winopts = { preview = { winopts = { cursorline = false } } },
            multiprocess = true,
            -- fn_transform = function(abs_file, opts)
            --     local entry = FzfLua.make_entry.file(rel_file, opts)
            --     -- ...
            --     -- prepends the frecency score if `display_score=true`
            --     -- filters out files that no longer exist if `stat_file=true`
            --     -- ...
            --     return entry
            -- end,
        },
        config = function(opts, _)
            require("fzf-lua-frecency").setup(opts)
        end,
    },
    {
        -- Search Everywhere
        -- Faster fzf in case of a large project
        -- DEPENDENCIES: Linux or Mac, fzf or skim, OPTIONAL: fd, rg, bat, delta, chafa
        "ibhagwan/fzf-lua",
        config = function(_, _)
            local fzf = require("fzf-lua")
            local actions = require("fzf-lua.actions")
            local defaults = require("fzf-lua.defaults").defaults

            ---@type boolean
            local show_excluded = false
            local cmd_opts = {
                excluded = {
                    files = {
                        fd = utils.concat_exclude_ptrn(defaults.files.fd_opts, "--exclude ", nil, "FZFLUA_EXCLUDE"),
                        rg = utils.concat_exclude_ptrn(defaults.files.rg_opts, "--glob ", "!", "FZFLUA_EXCLUDE", false),
                        find = utils.concat_exclude_ptrn(defaults.files.rg_opts, "\\! -path", nil, "FZFLUA_EXCLUDE"),
                        fzf_colors = true,
                    },
                    live_grep = {
                        rg = utils.concat_exclude_ptrn(defaults.grep.rg_opts, "--glob ", "!", "FZFLUA_EXCLUDE", false),
                        grep = utils.concat_exclude_ptrn(defaults.grep.grep_opts, "--exclude=", nil, "FZFLUA_EXCLUDE"),
                        fzf_colors = true,
                    },
                },
                notexcluded = {
                    files = {
                        fd = defaults.files.fd_opts,
                        rg = defaults.files.rg_opts,
                        find = defaults.files.rg_opts,
                        fzf_colors = {
                            true,
                            ["list-bg"] = { "bg", "WindowBackgroundShowExcluded" },
                            ["bg"] = { "bg", "WindowBackgroundShowExcluded" },
                            ["pointer"] = { "bg", "WindowBackgroundShowExcluded" },
                            ["gutter"] = { "bg", "WindowBackgroundShowExcluded" },
                        },
                    },
                    live_grep = {
                        rg = defaults.grep.rg_opts,
                        grep = defaults.grep.rg_opts,
                        fzf_colors = {
                            true,
                            ["list-bg"] = { "bg", "WindowBackgroundShowExcluded" },
                            ["bg"] = { "bg", "WindowBackgroundShowExcluded" },
                            ["pointer"] = { "bg", "WindowBackgroundShowExcluded" },
                            ["gutter"] = { "bg", "WindowBackgroundShowExcluded" },
                        },
                    },
                },
            }
            local function files_toggle_excluded(toggle, resume)
                if toggle == true then
                    show_excluded = not show_excluded
                end
                fzf.files({
                    resume = resume ~= nil and resume or true,
                    fd_opts = cmd_opts[not show_excluded and "excluded" or "notexcluded"].files.fd,
                    rg_opts = cmd_opts[not show_excluded and "excluded" or "notexcluded"].files.rg,
                    find_opts = cmd_opts[not show_excluded and "excluded" or "notexcluded"].files.find,
                    fzf_colors = cmd_opts[not show_excluded and "excluded" or "notexcluded"].files.fzf_colors,
                })
            end
            local function live_grep_toggle_excluded(toggle, resume)
                if toggle == true then
                    show_excluded = not show_excluded
                end
                fzf.live_grep({
                    resume = resume ~= nil and resume or true,
                    rg_opts = cmd_opts[not show_excluded and "excluded" or "notexcluded"].live_grep.rg,
                    grep_opts = cmd_opts[not show_excluded and "excluded" or "notexcluded"].live_grep.grep,
                    fzf_colors = cmd_opts[not show_excluded and "excluded" or "notexcluded"].live_grep.fzf_colors,
                })
            end

            fzf.setup({
                winopts = {
                    title_pos = "center",
                    height = 25, -- window height
                    width = 85,
                    row = 0.35,
                    zindex = 100,
                    preview = {
                        title_pos = "left",
                        scrollbar = false,
                        layout = "vertical",
                        vertical = "down:60%",
                        border = require("jb.borders").borders.dialog.split_bottom,
                    },
                    border = require("jb.borders").borders.dialog.default,
                },
                actions = {
                    -- Pickers inheriting these actions:
                    --   files, git_files, git_status, grep, lsp, oldfiles, quickfix, loclist,
                    --   tags, btags, args, buffers, tabs, lines, blines
                    files = {
                        true,
                        -- ["enter"] = function(selected, opts)
                        --     -- Switch to a normal buffer if current buffer is not a normal buffer
                        --     local curr_bufnr = vim.api.nvim_get_current_buf()
                        --     local curr_winid = vim.api.nvim_get_current_win()
                        --     local bufnr, winid = utils.get_win_with_normal_buffer(curr_bufnr)
                        --     if bufnr == curr_bufnr then
                        --         vim.api.nvim_set_current_win(curr_winid)
                        --     elseif winid ~= nil then
                        --         vim.api.nvim_set_current_win(winid)
                        --     end
                        --     vim.schedule(function()
                        --         actions.file_edit_or_qf(selected, opts)
                        --     end)
                        --     -- actions.file_edit_or_qf(selected, opts)
                        -- end,
                    },
                },
                fzf_colors = true,
                fzf_opts = {
                    ["--layout"] = "reverse",
                    ["--separator"] = "‾",
                },
                defaults = {
                    winopts = {
                        title_pos = "center",
                        height = 25, -- window height
                        width = 95,
                        row = 0.35,
                    },
                    cwd_prompt = false,
                    prompt = "   ",
                    header = false,
                },
                files = {
                    winopts = {
                        title = " Files ",
                        title_pos = "left",
                        height = 25, -- window height
                        width = 95,
                        row = 0.35,
                        -- Allows to turn on/off preview window
                        preview = {
                            -- hidden = true,
                            border = require("jb.borders").borders.dialog.split_bottom,
                        },
                        border = require("jb.borders").borders.dialog.default,
                    },
                    prompt = "   ",
                    -- formatter = { "path.filename_first", 2 },
                    -- formatter = "path.filename_first",
                    formatter = "path.dirname_first",
                    fd_opts = cmd_opts.excluded.files.fd,
                    rg_opts = cmd_opts.excluded.files.rg,
                    find_opts = cmd_opts.excluded.files.find,
                    previewer = "builtin",
                    actions = {
                        ["ctrl-e"] = function()
                            files_toggle_excluded(true)
                        end,
                    },
                },
                buffers = {
                    winopts = {
                        title = " Switcher ",
                        title_pos = "left",
                        preview = {
                            hidden = true,
                            border = require("jb.borders").borders.dialog.split_bottom,
                        },
                    },
                    prompt = "  ",
                    actions = {
                        ["alt-backspace"] = { fn = actions.buf_del, reload = true },
                    },
                },
                grep = {
                    winopts = {
                        title = " Find in Files ",
                        title_pos = "left",
                        height = 25, -- window height
                        width = 85,
                        row = 0.35,
                        border = require("jb.borders").borders.dialog.split_top,
                        preview = {
                            border = require("jb.borders").borders.dialog.split_bottom,
                        },
                    },
                    prompt = "   ",
                    previewer = "builtin",
                    formatter = "path.dirname_first",
                    -- formatter = "path.filename_first",
                    RIPGREP_CONFIG_PATH = vim.env.RIPGREP_CONFIG_PATH,
                    rg_opts = cmd_opts.excluded.live_grep.rg,
                    grep_opts = cmd_opts.excluded.live_grep.grep,
                    actions = {
                        ["ctrl-e"] = function()
                            live_grep_toggle_excluded(true)
                        end,
                    },
                },
                lsp = {
                    symbols = {
                        symbol_icons = Utils.icons.kind,
                        symbol_hl = function(s)
                            -- `JBIcon<Kind>` generated in jb.nvim colorscheme
                            return "JBIcon" .. s:lower()
                        end,
                    },
                },
                previewers = {
                    builtin = {
                        extensions = {
                            ["svg"] = { "chafa", "{file}" },
                            ["png"] = { "chafa" },
                            ["jpg"] = { "viu", "-b" },
                        },
                        title_fnamemodify = function(s)
                            -- Get absolute path of parent directory
                            local absParentPath = vim.fn.fnamemodify(s, ":h")
                            -- Convert absolute path to path relative to cwd
                            local relParentPath = vim.fn.fnamemodify(absParentPath, ":~:.")

                            local path = require("fzf-lua.path")
                            local name = path.tail(s)

                            -- Handle case when file is outside of cwd
                            if relParentPath:find("^%./") then
                                relParentPath = relParentPath:sub(3) -- Remove leading ./
                            end

                            -- Return filename with relative parent path
                            return name .. " - " .. relParentPath
                        end,
                        snacks_image = { enabled = true, render_inline = false },
                    },
                },
            })

            -- Go to file
            vim.keymap.set("n", "<leader>gf", function()
                local curr_time = os.time()
                if (curr_time - last_go_to_file_time) < resume_within_seconds then
                    fzf.files({ resume = true })
                else
                    fzf.files()
                end
                last_go_to_file_time = curr_time
            end, { noremap = true, desc = "Search: [g]o to [f]ile" })

            -- Find in path
            vim.keymap.set("n", "<leader>fp", function()
                local curr_time = os.time()
                if (curr_time - last_find_in_path_time) < resume_within_seconds then
                    fzf.live_grep({ resume = true })
                else
                    fzf.live_grep()
                end
                last_find_in_path_time = curr_time
            end, { noremap = true, desc = "Search: [f]ind in [p]ath" })

            -- Go to buffer (Similar to Switcher in Intellij)
            vim.keymap.set("n", "<leader>gb", fzf.buffers, { noremap = true, desc = "[g]o to [b]uffer" })
        end,
    },
}

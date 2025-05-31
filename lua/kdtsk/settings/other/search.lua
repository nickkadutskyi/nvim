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
        -- Search Everywhere
        -- Faster fzf in case of a large project
        -- DEPENDENCIES: Linux or Mac, fzf or skim, OPTIONAL: fd, rg, bat, delta, chafa
        "ibhagwan/fzf-lua",
        dependencies = {
            "nickkadutskyi/jb.nvim",
        },
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
                            hidden = true,
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
                        ["backspace"] = { fn = actions.buf_del, reload = true },
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
            -- Go to git status
            -- vim.keymap.set("n", "<leader>ggs", fzf.git_status, { noremap = true })
            -- Go to git commits
            vim.keymap.set("n", "<leader>ggc", fzf.git_commits, { noremap = true })
            -- Go to git commits of current buffer
            vim.keymap.set("n", "<leader>ggb", fzf.git_bcommits, { noremap = true })
        end,
    },
}

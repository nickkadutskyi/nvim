return {
    {
        "nvim-lualine/lualine.nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            "akinsho/toggleterm.nvim",
        },
        opts = {
            options = {
                globalstatus = true,
                -- component_separators = { left = "", right = "" },
                -- component_separators = { left = "|", right = "|" },
                component_separators = { left = "", right = "" },
                -- section_separators = { left = "", right = "" },
                section_separators = { left = "", right = "" },
                always_divide_middle = true,
            },
            sections = {
                lualine_a = {
                    -- project abbreviation
                    function()
                        local projectName = vim.fs.basename(vim.fn.getcwd())
                        local firstChars = {}
                        for str in string.gmatch(projectName, "([^-_,%s.]+)") do
                            table.insert(firstChars, string.upper(string.sub(str, 1, 1)))
                        end
                        return (firstChars[1] or "")
                            .. (firstChars[2] or string.upper(string.sub(projectName, 2, 2)) or "")
                    end,
                    -- project name
                    function()
                        return vim.fs.basename(vim.fn.getcwd())
                    end,
                },
                lualine_b = {
                    "branch",
                    -- "diff",
                    {
                        "filetype",
                        padding = { left = 1, right = 0 },
                        icon_only = true,
                    },
                    -- function()
                    --     return '%{&ft == "toggleterm" ? "terminal (".b:toggle_number.")" : ""}'
                    -- end,
                    {
                        "filename",
                        file_status = true,
                        newfile_status = true,
                        path = 1,
                        symbols = { newfile = "[new]", unnamed = "[no name]" },
                        fmt = function(name, _)
                            local filePath, rest = name:match("(.+)%s*(%[*.*%]*)")
                            local parentPath = vim.fn.fnamemodify(filePath, ":h")
                            local fileName = vim.fs.basename(filePath)

                            if string.match(name, "term://.*toggleterm#.*") then
                                local terms = require("toggleterm.terminal").get_all()
                                -- local terms = require("toggleterm.termial").get_all(true)
                                return "Term id: " .. (vim.b.toggle_number or "0") .. " (tot: " .. #terms .. ") " .. (rest or "")
                            end

                            if string.len(filePath) > 50 then
                                local rightPart = vim.fs.basename(parentPath) .. "/" .. fileName
                                local leftPart = string.sub(filePath, 1, 50 - string.len(rightPart))
                                return leftPart .. "../" .. rightPart .. " " .. (rest or "")
                            else
                                return filePath .. " " .. (rest or "")
                            end
                        end,
                    },
                },
                lualine_c = {
                    {
                        "navic",

                        -- Component specific options
                        color_correction = "dynamic", -- Can be nil, "static" or "dynamic". This option is useful only when you have highlights enabled.
                        -- Many colorschemes don't define same backgroud for nvim-navic as their lualine statusline backgroud.
                        -- Setting it to "static" will perform a adjustment once when the component is being setup. This should
                        --   be enough when the lualine section isn't changing colors based on the mode.
                        -- Setting it to "dynamic" will keep updating the highlights according to the current modes colors for
                        --   the current section.

                        navic_opts = {
                            click = true,
                            separator = "  ",
                        }, -- lua table with same format as setup's option. All options except "lsp" options take effect when set here.
                    },
                },
                lualine_x = {
                    "diagnostics",
                },
                lualine_y = {
                    "searchcount",
                    "progress",
                    "location",
                },
                lualine_z = {
                    {
                        "mode",
                        fmt = function(mode)
                            local modes = {
                                ["NORMAL"] = "NOR",
                                ["O-PENDING"] = "OPND",
                                ["VISUAL"] = "VIS",
                                ["V-LINE"] = "VISL",
                                ["V-BLOCK"] = "VISB",
                                ["SELECT"] = "SEL",
                                ["S-LINE"] = "SELL",
                                ["S-BLOCK"] = "SELB",
                                ["INSERT"] = "INS",
                                ["REPLACE"] = "RPLC",
                                ["V-REPLACE"] = "VRPL",
                                ["COMMAND"] = "COM",
                                ["EX"] = "EX",
                                ["MORE"] = "MORE",
                                ["CONFIRM"] = "CONF",
                                ["SHELL"] = "SHEL",
                                ["TERMINAL"] = "TERM",
                            }
                            return modes[mode] or mode
                        end,
                    },
                },
            },
            inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = { "filename" },
                lualine_x = { "location" },
                lualine_y = {},
                lualine_z = {},
            },
        },
        config = function(_, opts)
            require("lualine").setup(opts)
            -- get a list of all git files into global variable
            vim.system({ "git", "rev-parse", "--is-inside-work-tree" }, { text = true }, function(o)
                if o.code == 0 and o.stdout:match("true") then
                    vim.system(
                        { "sh", "-c", 'git -C "$(git rev-parse --show-toplevel)" ls-files | xargs basename' },
                        { text = true },
                        function(git_files)
                            if git_files.code == 0 then
                                vim.g.all_files_str = table.concat(vim.split(git_files.stdout, "\n"), ", ")
                            end
                        end
                    )
                end
            end)
        end,
    },
}

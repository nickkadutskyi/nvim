return {
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            options = {
                globalstatus = true,
                -- component_separators = { left = "", right = "" },
                -- component_separators = { left = "|", right = "|" },
                component_separators = { left = "", right = "" },
                section_separators = { left = "", right = "" },
                always_divide_middle = true,
            },
            sections = {
                lualine_a = {
                    -- project abbreviation
                    function()
                        local rootPath = vim.fn.getcwd()
                        local inputstr = vim.fs.basename(rootPath)
                        local firstChars = {}
                        for str in string.gmatch(inputstr, "([^-_,%s.]+)") do
                            table.insert(firstChars, string.upper(string.sub(str, 1, 1)))
                        end
                        return (firstChars[1] or "")
                            .. (firstChars[2] or string.upper(string.sub(inputstr, 2, 2)) or "")
                    end,
                    -- project name
                    function()
                        local rootPath = vim.fn.getcwd()
                        return vim.fs.basename(rootPath)
                    end,
                },
                lualine_b = {
                    "branch",
                    "diff",
                    "diagnostics",
                    {
                        "filetype",
                        padding = { left = 1, right = 0 },
                        icon_only = true,
                    },
                    {
                        "filename",
                        file_status = true,
                        newfile_status = true,
                        path = 1,
                        symbols = { newfile = "[new]", unnamed = "[no name]" },
                        fmt = function(name, fmt)
                            local filePath, rest = name:match("(.+)%s*(.*)")
                            local fileName = vim.fs.basename(filePath)
                            local files = vim.g.all_files_str
                            local _, c = files:gsub(", " .. (fileName or "") .. ", ", "")
                            if c > 1 and fileName ~= nil then
                                return filePath .. " " .. (rest or "")
                            elseif fileName ~= nil then
                                return fileName .. " " .. (rest or "")
                            else
                                return name
                            end
                        end,
                    },
                    "searchcount",
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
                            separator = "  ",
                        }, -- lua table with same format as setup's option. All options except "lsp" options take effect when set here.
                    },
                },
                lualine_x = {},
                lualine_y = { "progress", "location" },
                lualine_z = { "mode" },
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
    },
}

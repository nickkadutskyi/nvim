-- Fields
local lTrunc = "%<" -- where to truncate the line if too long
local lFile = "%f " -- file path
local lStatus = "%m%r%w" -- help flag, modified, readonly and preview
local lStatusSpace = "%{&modified||&readonly||&previewwindow ? ' ' :''}" -- adds space conditionally
local lAR = "%=" -- right align
local lPosition = "%-10.(%l,%c%V%) %P"
local cFileType = "%#FileTypeColor#"
local cReset = "%#StatusLine#"

local function getLocation()
    return require("nvim-navic").get_location()
end

local function getMode()
    return require("nickkadutskyi.mode").get()
end

local function getGitBranch()
    if vim.b.gitsigns_status_dict ~= nil then
        return "  " .. vim.b.gitsigns_status_dict.head
    else
        return ""
    end
end

local function getGitStatus()
    if vim.b.gitsigns_status ~= nil then
        return " " .. vim.b.gitsigns_status
    else
        return ""
    end
end

local function getSearchCount()
    local sc = vim.fn.searchcount()

    if vim.v.hlsearch == 0 then
        return ""
    end

    local icon = " "
    if sc.incomplete == 1 then -- timed out
        return icon .. "?/?? "
    elseif sc.incomplete == 2 then -- max count exceeded
        if sc.total > sc.maxcount and sc.current > sc.maxcount then
            return icon .. ">" .. sc.current .. "/>" .. sc.total .. " "
        elseif sc.total > sc.maxcount then
            return icon .. sc.current .. "/>" .. sc.total .. " "
        end
    elseif sc.total ~= nil then
        return icon .. sc.current .. "/" .. sc.total .. " "
    else
        return ""
    end
end

local function getAbbreviation(inputstr)
    local firstChars = {}
    for str in string.gmatch(inputstr, "([^-_,%s.]+)") do
        table.insert(firstChars, string.upper(string.sub(str, 1, 1)))
    end
    if next(firstChars) == nil then
        return string.upper(string.sub(inputstr, 1, 1))
    else
        return (firstChars[1] or "") .. (firstChars[2] or "")
    end
end

local function getProjectName()
    local rootPath = vim.fn.getcwd()
    return " " .. vim.fs.basename(rootPath)
end

local function getFileTypeIcon()
    local fileName = vim.fs.basename(string.gsub(vim.api.nvim_buf_get_name(0), vim.loop.cwd(), ""))
    local fileExtension = string.match(fileName, "%.(%a+)$")
    local icon, color = require("nvim-web-devicons").get_icon_color(fileName, fileExtension)
    local hBg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("StatusLine")), "bg#")
    vim.api.nvim_set_hl(0, "FileTypeColor", { fg = color, bg = hBg })
    return " " .. icon .. " "
end

local function getFileName()
    local rootPath = vim.fn.getcwd()
    local relativePath = string.gsub(vim.api.nvim_buf_get_name(0), rootPath, "")
    local fileName = vim.fs.basename(relativePath)
    local files = vim.g.all_files_str
    local _, c = files:gsub(", " .. fileName .. ", ", "")
    if c > 1 then
        return "%f "
    else
        return fileName .. " "
    end
end

-- Generator fn
function StatusLine()
    return table.concat({
        "[" .. getAbbreviation(getProjectName()) .. "]",
        getProjectName(),
        getGitBranch(),
        getGitStatus(),
        cFileType,
        getFileTypeIcon(),
        cReset,
        getFileName(),
        -- lFile,
        lStatus,
        lStatusSpace,
        getSearchCount(),
        lTrunc,
        getLocation(),
        " ",
        lAR,
        getMode(),
        lPosition,
    })
end

-- Setup
-- Show single statusline for all splits
vim.opt.laststatus = 3
-- Init statusline
vim.o.statusline = "%!v:lua.StatusLine()"
-- vim.o.statusline =
-- 	"%<%f %h%m%r %{%v:lua.require'nvim-navic'.get_location()%} %=%{%v:lua.require'nickkadutskyi.mode'.get()%}%-10.(%l,%c%V%) %P"

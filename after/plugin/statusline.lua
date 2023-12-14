-- Fields
local lS = "%<" --
local lFile = "%f " -- file path
local lStatus = "%h%m%r%w" -- help flag, modified, readonly and preview
local lStatusSpace = "%{&filetype=='help'||&modified||&readonly||&previewwindow ? ' ' :''}" -- adds space conditionally
local lAR = "%=" -- right align
local lPosition = "%-10.(%l,%c%V%) %P"

local function getLocation()
	return require("nvim-navic").get_location()
end

local function getMode()
	return require("nick_kadutskyi.mode").get()
end

local function getGitBranch()
	if vim.b.gitsigns_status_dict ~= nil then
		return vim.b.gitsigns_status_dict.head .. " "
	else
		return ""
	end
end

local function getSearchCount()
	local sc = vim.fn.searchcount()
	if sc.total ~= nil then
		return sc.current .. "/" .. sc.total .. " "
	else
		return ""
	end
end
-- Generator fn
function StatusLine()
	return table.concat({
		lS,
		getGitBranch(),
		lFile,
		lStatus,
		lStatusSpace,
		getSearchCount(),
		getLocation(),
		" ",
		lAR,
		getMode(),
		lPosition,
	})
end
-- Setup
vim.o.statusline = "%!v:lua.StatusLine()"
-- vim.o.statusline =
-- 	"%<%f %h%m%r %{%v:lua.require'nvim-navic'.get_location()%} %=%{%v:lua.require'nick_kadutskyi.mode'.get()%}%-10.(%l,%c%V%) %P"

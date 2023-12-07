local M = {}

local modes = {
	["n"] = "NOR",
	["no"] = "NOR",
	["v"] = "VIS",
	["V"] = "VISL",
	["^v"] = "VISB",
	["s"] = "SEL",
	["S"] = "SELL",
	[""] = "SELB",
	["i"] = "INS",
	["ic"] = "INS",
	["R"] = "REP",
	["Rv"] = "VISR",
	["c"] = "COMM",
	["cv"] = "VIME",
	["ce"] = "EX",
	["r"] = "PROM",
	["rm"] = "MOAR",
	["r?"] = "CONF",
	["!"] = "SHEL",
	["t"] = "TERM",
}

local Mode = function()
	local current_mode = vim.api.nvim_get_mode().mode
	local defined_mode = modes[current_mode]
	if defined_mode ~= nil then
		return string.format(" %-4s ", modes[current_mode]):upper()
	else
		return string.format(" %-4s ", current_mode):upper()
	end
end

M.get = Mode

return M

local M = {}

local defaultDeclaration = {
    copilot_allowed_paths = true,
}
M.default = {
    copilot_allowed_paths = {
        "~/Developer",
        "~/.config/nvim",
    },
    copilot_not_allowed_paths = {
        "~/Library/Mobidle Documents",
    },
}

setmetatable(M.default, {
    __newindex = function(t, n, v)
        if not defaultDeclaration[n] then
            error("Attempt to write to undeclared default config: " .. n, 2)
        else
            rawset(t, n, v) -- do the actual set
        end
    end,
    __index = function(_, n)
        if not defaultDeclaration[n] then
            error("Attempt to read undeclared default config: " .. n, 2)
        else
            return nil
        end
    end,
})

return M

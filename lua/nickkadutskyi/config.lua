local M = {}

local defaultDeclaration = {
    copilot_allowed_paths = true,
}
M.default = {
    copilot_allowed_paths = {
        "~/Developer",
        "~/Library/Mobile Documents/com~apple~CloudDocs/Sync/HOME/.config/nvim",
        "~/Library/Mobile Documents/com~apple~CloudDocs/Sync/HOME/.config/nixpkgs",
        "~/Library/Mobile Documents/com~apple~CloudDocs/Sync/HOME/.config/alacritty",
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

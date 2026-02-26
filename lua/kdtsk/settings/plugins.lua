---This is a place where all plugins are loaded

local gh = function(x)
    return "https://github.com/" .. x
end
vim.pack.add({
    { src = gh("rcarriga/nvim-notify"), version = "ab98fecfe24d31fa03e0b3dcfc7c506c0f9c34c7" },
})

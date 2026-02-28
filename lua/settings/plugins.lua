local spec_builder = require("ide.spec.builder")
local g = require("ide.utils").prepend_fn("https://github.com/")

--- Define all plugins with their src here. Feature files patch via name only.
spec_builder.add({
    { src = g("rcarriga/nvim-notify"), version = "ab98fecfe" },
})

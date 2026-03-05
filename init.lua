require("ide").setup({
    imports = {
        -- In this file we define all the plugins with their `src` so we load it first
        -- to keep the order of how plugins are going to be loaded deterministic.
        -- This will help with dependendcies. Keep in mind if plugin is loaded on event
        -- then it's going to be out of order.
        "settings.plugins",

        "settings.appearance",
        "settings.behavior",
        "settings.keymap",
        "settings.editor",
        "settings.version_control",
        "settings.tools",
        "settings.advanced",
    },
})

---@deprecated Moving config to vim.pack
require("kdtsk")

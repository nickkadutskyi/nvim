-- using byte-compilation cache
vim.loader.enable()

require("ide").setup({
    imports = {
        -- In this file we define all the plugins with their `src` so we load it first
        -- to keep the order of how plugins are going to be loaded deterministic.
        -- This will help with dependendcies. Keep in mind if plugin is loaded on event
        -- then it's going to be out of order.
        "settings.plugins",

        -- Customizes IDE (non-editor-specific parts) appearance and behavior
        "settings.appearance",
        "settings.behavior",
        -- All keymaps
        "settings.keymap",
        -- Configures all editor specific parts (completion, code style and quality, color scheme, etc.)
        "settings.editor",
        -- Everything related to version control systems (e.g. Git)
        "settings.version_control",
        -- Provides language-specific settings (Lazy modules provide `opts` but configured in other areas)
        "settings.languages",
        -- Other tools (terminal, task runner, AI assistant, etc.)
        "settings.tools",
        -- Uncategorized and rarely changed settings
        "settings.advanced",
    },
})

local spec_builder = require("ide.spec.builder")

spec_builder.add({
    "ThePrimeagen/99",
    --- @type _99.Options
    opts = {
        model = "github-copilot/claude-opus-4.6",
        tmp_dir = "./tmp",
        completion = {
            custom_rules = {
                "scratch/custom_rules/",
            },
            --- Configure @file completion (all fields optional, sensible defaults)
            files = {
                -- enabled = true,
                -- max_file_size = 102400,     -- bytes, skip files larger than this
                -- max_files = 5000,            -- cap on total discovered files
                -- exclude = { ".env", ".env.*", "node_modules", ".git", ... },
            },
            --- File Discovery:
            --- - In git repos: Uses `git ls-files` which automatically respects .gitignore
            --- - Non-git repos: Falls back to filesystem scanning with manual excludes
            --- - Both methods apply the configured `exclude` list on top of gitignore

            --- What autocomplete engine to use. Defaults to native (built-in) if not specified.
            source = "blink", -- "native" (default), "cmp", or "blink"
        },
        md_files = {
            "AGENT.md",
        },
    },
})

local spec = require("ide.spec.builder")

spec.add({ "nvim-treesitter", opts = { ensure_installed = { "php", "phpdoc" } } })

spec.add({
    "mfussenegger/nvim-lint",
    ---@type ide.Opts.Lint
    opts = {
        linters_by_ft = {
            php = {
                { "php", nil, nil, true },
                { "phpcs", { ".phpcs.xml", "phpcs.xml" } },
                { "phpinsights", { "phpinsights.php" } },
                { "phpm", { "phpmd.xml" } },
                { "phpstan", { "phpstan.neon", "phpstan.neon.dist", "phpstan.dist.neon" } },
                -- TODO: Consider providing a function that will check if it's enabled via LSP
                -- Explicitly disable it via .editorconfig since might use it via LSP
                { "psalm", { "psalm.xml", "psalm.xml.dist" } },
            },
        },
        -- TODO: move php linters from kdtsk to ide utils
        linters = {
            phpcs = Utils.php.linters.phpcs,
            phpmd = Utils.php.linters.phpmd,
            phpstan = Utils.php.linters.phpstan,
            psalm = Utils.php.linters.psalm,
            phpinsights = {
                cmd = function()
                    return Utils.php.find_executable("phpinsights") or "phpinsights"
                end,
                nix_pkg = "php84Packages.phpinsights",
            },
        },
    },
})

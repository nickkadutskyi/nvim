local spec = require("ide.spec.builder")

spec.add({ "nvim-treesitter", opts = { ensure_installed = { "twig" } } })

spec.add({
    "nvim-lint",
    ---@type ide.Opts.Lint
    opts = {
        linters_by_ft = {
            twig = { { "twig-cs-fixer", { ".twig-cs-fixer.dist.php", ".twig-cs-fixer.php", "symfony.lock" } } },
        },
    },
})

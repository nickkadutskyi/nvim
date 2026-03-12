local spec_builder = require("ide.spec.builder")

spec_builder.add({ "nvim-treesitter", opts = { ensure_installed = { "html", "html_tags" } } })


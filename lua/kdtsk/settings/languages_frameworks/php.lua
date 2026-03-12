---@type LazySpec
return {
    {
        "nvim-lspconfig", -- Language Servers
        opts = function(_, opts)
            return vim.tbl_deep_extend("force", opts, {
                ---@type table<string,vim.lsp.ConfigLocal>
                servers = {
                    ["intelephense"] = {
                        enabled = Utils.tools.is_component_enabled("php", "intelephense", Utils.tools.purpose.LSP, {
                            ".intelephense.json",
                            ".intelephense/config.json",
                        }, function()
                            -- only enable if we find an executable in the project
                            local executable = "intelephense"
                            local cwd = vim.uv.cwd()

                            -- Only look for local executables
                            local _, found = Utils.tools.find_executable({
                                "./" .. executable,
                                "./" .. executable .. ".phar",
                                "vendor/bin/" .. executable,
                                "vendor/bin/" .. executable .. ".phar",
                                ".devenv/profile/bin/" .. executable,
                            }, executable .. "_", cwd)

                            return found
                        end),
                        local_config = ".intelephense.json",
                        nix_pkg = "intelephense",
                        bin = Utils.php.find_executable("intelephense"),
                        init_options = {
                            licenceKey = vim.fn.expand("/run/secrets/php/intelephense_license"),
                        },
                        settings = {
                            intelephense = {
                                telemetry = {
                                    enabled = false,
                                },
                                files = {
                                    exclude = {
                                        -- These are causing high CPU usage
                                        "**/.devenv/**",
                                        "**/.direnv/**",
                                        "**/.jj/**",
                                        "**/.idea/**",
                                        "**/.git/**",
                                        "**/.svn/**",
                                        "**/.hg/**",
                                        "**/CVS/**",
                                        "**/.DS_Store/**",
                                        "**/node_modules/**",
                                        "**/bower_components/**",
                                        "**/vendor/**/{Tests,tests}/**",
                                        "**/.history/**",
                                        "**/vendor/**/vendor/**",
                                        -- This is for WordPress Starter Projects
                                        "**/public/wp/**",
                                        "**/public/content/plugins/vendor-**",
                                        "**/public/content/mu-plugins/vendor-**",
                                        "**/public/content/themes/vendor-**",
                                    },
                                    maxSize = 10000000,
                                },
                            },
                        },
                    },
                    ["phan"] = {
                        -- `root_dir` already checks for composer.json and .git
                        -- To enable it create .phan/config.php with contents
                        enabled = Utils.tools.is_component_enabled("php", "phan", Utils.tools.purpose.LSP, {
                            ".phan/config.php",
                        }),
                        nix_pkg = "php84Packages.phan",
                        bin = Utils.php.find_executable("phan"),
                    },
                    ["phpactor"] = {
                        -- Requires proper project root files (composer.json, .git, .phpactor.json, .phpactor.yml)
                        -- Use it if executable is provided and if there is proper root
                        -- To enable it create either .phpactor.json or .phpactor.yml with contents
                        enabled = Utils.tools.is_component_enabled("php", "phpactor", Utils.tools.purpose.LSP, {
                            ".phpactor.json",
                            ".phpactor.yml",
                        }),
                        nix_pkg = "phpactor",
                        bin = Utils.php.find_executable("phpactor"),
                    },
                    ["psalm"] = {
                        -- `root_dir` already checks for psalm.xml or psalm.xml.dist
                        -- To enable it create either of these files and configure it
                        enabled = Utils.tools.is_component_enabled("php", "psalm", Utils.tools.purpose.LSP, {
                            "psalm.xml",
                            "psalm.xml.dist",
                        }),
                        nix_pkg = "php84Packages.psalm",
                        bin = Utils.php.find_executable("psalm"),
                    },
                },
            })
        end,
    },
}

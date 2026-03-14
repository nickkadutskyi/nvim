---@type LazySpec
return {
    {
        "nvim-lspconfig", -- Language Servers
        opts = function(_, opts)
            local cwd = vim.fn.getcwd()

            local servers = {
                ["twiggy_language_server"] = {
                    enabled = Utils.tools.is_component_enabled(
                        "twig",
                        "twiggy_language_server",
                        Utils.tools.purpose.LSP,
                        { ".twig-cs-fixer.dist.php", ".twig-cs-fixer.php", "symfony.lock" }
                    ),
                    bin = Utils.js.find_executable("twiggy-language-server"),
                    settings = {
                        twiggy = {
                            framework = "symfony",
                            phpExecutable = "php",
                            symfonyConsolePath = "bin/console",
                            diagnostics = {
                                twigCsFixer = false,
                            },
                        },
                    },
                },
                ["vimfony"] = {
                    enabled = Utils.tools.is_component_enabled(
                        "symfony",
                        "vimfony",
                        Utils.tools.purpose.LSP,
                        { "symfony.lock" }
                    ),
                    -- bin = Utils.php.find_executable("vimfony"),
                    cmd = { "vimfony" },
                    filetypes = { "php", "twig", "yaml", "xml" }, -- You can remove file types if you don't like it, but then it won't work in those files
                    root_markers = { ".git" },
                    single_file_support = true,
                    init_options = {
                        roots = { "templates" },
                        container_xml_path = (cwd .. "/var/cache/dev/App_KernelDevDebugContainer.xml"),
                        -- OR:
                        -- container_xml_path = {
                        --   (git_root .. "/var/cache/dev/App_KernelDevDebugContainer.xml"),
                        --   (git_root .. "/var/cache/website/dev/App_KernelDevDebugContainer.xml"),
                        --   (git_root .. "/var/cache/admin/dev/App_KernelDevDebugContainer.xml"),
                        -- },
                        vendor_dir = cwd .. "/vendor",
                        -- Optional:
                        -- php_path = "/usr/bin/php",
                    },
                },
            }
            return vim.tbl_deep_extend("force", opts, {
                ---@type table<string,vim.lsp.ConfigLocal>
                servers = servers,
            })
        end,
    },
}

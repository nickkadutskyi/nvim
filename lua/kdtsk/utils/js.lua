---@class kdtsk.utils.js
local M = {}

---Find the PHP executable in the current working directory in PHP specific
---locations or globally with cache support to avoid repeated lookups.
---@param executable string The name of the PHP executable to find (e.g., "phpcs", "phpstan")
---@param cwd? string Optional current working directory to search in (defaults to vim.fn.getcwd())
---@return string|nil
function M.find_executable(executable, cwd)
    local bin, found = Utils.tools.find_executable({
        "./node_modules/.bin/" .. executable,
        ".devenv/profile/bin/" .. executable,
    }, executable, cwd)
    return found and bin or nil
end

M.servers = {
    ["eslint"] = {
        nix_pkg = "vscode-langservers-extracted",
    },
    ["ts_ls"] = {
        enabled = not (
                Utils.tools.is_component_enabled("vue", "vue_ls", Utils.tools.purpose.LSP)
                or Utils.tools.is_component_enabled("typescript", "vtsls", Utils.tools.purpose.LSP)
            )
            and (
                Utils.tools.is_component_enabled("typescript", "ts_ls", Utils.tools.purpose.LSP, { "tsconfig.json" })
                or Utils.tools.is_component_enabled("javascript", "ts_ls", Utils.tools.purpose.LSP, { "jsconfig.jso " })
            ),
        nix_pkg = "typescript-language-server",
        init_options = {
            hostInfo = "neovim",
            preferences = {
                includeCompletionsForModuleExports = true,
                includeCompletionsForImportStatements = true,
                importModuleSpecifierPreference = "relative",
            },
            -- Add plugins in corresponding files
            plugins = {},
        },
        filetypes = vim.lsp.config["ts_ls"].filetypes or {},
        on_attach = function(client, bufnr)
            -- ts_ls provides `source.*` code actions that apply to the whole file. These only appear in
            -- `vim.lsp.buf.code_action()` if specified in `context.only`.
            vim.api.nvim_buf_create_user_command(bufnr, "LspTypescriptSourceAction", function()
                local source_actions = vim.tbl_filter(function(action)
                    return vim.startswith(action, "source.")
                end, client.server_capabilities.codeActionProvider.codeActionKinds)

                vim.lsp.buf.code_action({
                    context = {
                        only = source_actions,
                    },
                })
            end, {})

            -- Since 3.0.2, semantic tokens are handled
            -- on the vue_ls side rather than tsserver,
            -- and the token name has changed, to adopt
            -- this change you have to:
            if vim.bo.filetype == "vue" then
                client.server_capabilities.semanticTokensProvider.full = false
            else
                client.server_capabilities.semanticTokensProvider.full = true
            end
        end,
    },
    ["vtsls"] = {
        nix_pkg = "vtsls",
        on_attach = function(client)
            -- Since 3.0.2, semantic tokens are handled
            -- on the vue_ls side rather than tsserver,
            -- and the token name has changed, to adopt
            -- this change you have to:
            if vim.bo.filetype == "vue" then
                client.server_capabilities.semanticTokensProvider.full = false
            else
                client.server_capabilities.semanticTokensProvider.full = true
            end
        end,
        filetypes = vim.lsp.config["vtsls"].filetypes or {},
        settings = {
            complete_function_calls = true,
            vtsls = {
                enableMoveToFileCodeAction = true,
                experimental = {
                    maxInlayHintLength = 30,
                    completion = {
                        enableServerSideFuzzyMatch = true,
                    },
                },
                tsserver = {
                    -- Add plugins in corresponding files
                    globalPlugins = {},
                },
            },
            javascript = {
                updateImportsOnFileMove = "always",
            },
            typescript = {
                updateImportsOnFileMove = { enabled = "always" },
                suggest = {
                    completeFunctionCalls = true,
                },
                inlayHints = {
                    enumMemberValues = { enabled = true },
                    functionLikeReturnTypes = { enabled = true },
                    parameterNames = { enabled = "literals" },
                    parameterTypes = { enabled = true },
                    propertyDeclarationTypes = { enabled = true },
                    variableTypes = { enabled = false },
                },
                preferences = {
                    includeCompletionsForModuleExports = true,
                    includeCompletionsForImportStatements = true,
                    importModuleSpecifier = "non-relative",
                },
            },
        },
    },
}

return M

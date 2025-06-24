# Neovim Configuration Context

## Build/Lint/Test Commands
- **Lint Lua**: `selene .` (configured in selene.toml with Neovim standard)
- **Format Lua**: `stylua .` (via conform.nvim)
- **Check Lua**: `luacheck .` (via nvim-lint)
- **LSP Check**: Use built-in LSP diagnostics (lua_ls server)
- **Plugin Management**: `nvim --headless "+Lazy! sync" +qa` (Lazy.nvim)

## Code Style Guidelines
- **Indentation**: 2 spaces (tabstop=2, shiftwidth=2, expandtab=true)
- **Line Length**: No explicit limit (handled via .editorconfig)
- **Imports**: Use `require("module.path")` format, organize by category
- **Module Structure**: Return table with LazySpec for plugins, use `---@type LazySpec`
- **Comments**: Use `--` for single line, `---` for documentation annotations
- **Naming**: snake_case for variables/functions, PascalCase for classes/types
- **Error Handling**: Use `pcall()` for safe requires, assert() for validation
- **Global Access**: Use `vim` global directly (configured in lua_ls settings)
- **Type Annotations**: Use LuaLS annotations (`---@param`, `---@return`, `---@type`)
- **File Organization**: Modular structure under `lua/kdtsk/` with settings/ and utils/
- **Plugin Config**: Use opts table for simple config, config function for complex setup
- **Utilities**: Access via global `Utils` table (set in init.lua as `_G.Utils`)
- **Mason Integration**: Handle tool installation via Mason or Nix fallback
- **Keymaps**: Use descriptive desc field, follow `[g]o to [r]efactor` pattern for LSP
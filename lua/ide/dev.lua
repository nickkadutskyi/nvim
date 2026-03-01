--- MODULE DEFINITION ----------------------------------------------------------

---@class ide.Dev
local M = {}
local I = {}

---@type ide.Dev.Config
I.config = {
    path = "~/Documents",
    patterns = {},
    fallback = false,
}

--- Configure the dev loader. Call before spec_builder.add() calls are made.
---@param opts? ide.Dev.Config
function M.setup(opts)
    opts = opts or {}
    vim.validate("opts", opts, "table")
    I.config = vim.tbl_deep_extend("force", I.config, opts)
    I.config.path = vim.fn.expand(I.config.path)
end

--- Resolve a local dev directory for a spec.
--- Returns the local path string when dev mode applies, or nil to keep spec.src.
---@param spec vim.pack.Spec
---@return string|nil
function M.resolve(spec)
    local data = spec.data or {}
    local is_dev = data.dev

    -- Auto-detect via patterns when dev is not explicitly set
    if is_dev == nil and spec.src then
        for _, pattern in ipairs(I.config.patterns) do
            if spec.src:find(pattern, 1, true) then
                is_dev = true
                break
            end
        end
    end

    if not is_dev then
        return nil
    end

    -- Build the local directory path
    local dev_dir = I.config.path .. "/" .. spec.name

    -- Fallback: revert to remote if the local directory does not exist
    if I.config.fallback and vim.fn.isdirectory(dev_dir) ~= 1 then
        return nil
    end

    return dev_dir
end

return M

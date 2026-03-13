local utils = require("ide.utils")

--- MODULE DEFINITION ----------------------------------------------------------
local M = {}
local I = {}

---@type ide.Opts.Lsp
I.opts = {}
I.configured = false
I.autocmdid = nil

---@param opts ide.Opts.Lsp
function M.setup(opts)
    I.opts = opts or {}
    I.opts.clients = I.opts.clients or {}
    require("editorconfig").properties.tools_lsp = I.handle_tools_lsp_declaration
    I.configure_lsp_clients(opts.clients)

    -- In case we don't have tools_lsp in .editorconfig we still want to configure LSP clients
    -- Running this delayed to ensure we create our autocmd for BufReadPost
    -- after the one created by editorconfig.lua plugin
    I.autocmdid = utils.run.later(function()
        utils.autocmd.create("BufReadPost", {
            group = "ide-lsp",
            callback = function(e)
                vim.api.nvim_del_autocmd(I.autocmdid)
                if I.configured then
                    return
                end

                I.handle_tools_lsp_declaration(e.buf, "", {})
            end,
        })
    end)
end

---@param clients table<string, ide.Lsp.Client>
function I.configure_lsp_clients(clients)
    for name, cfg in pairs(clients or {}) do
        -- Configuring it in a non-blocking way thus it's important to do the same
        -- when resolving binaries later and enabling so that it ends up after
        -- vim.lsp.config() call in  the same queue
        utils.run.later(function()
            if type(cfg.enabled) == "table" then
                cfg.enabled = utils.tool.is_enabled(cfg.enabled--[[@as ide.ToolTest]])
            end
            vim.lsp.config(name, cfg)
        end)
    end
end

--- Handling editorconfig integration for tools_lsp declaration
---@param bufnr integer
---@param val string
---@param opts? table
function I.handle_tools_lsp_declaration(bufnr, val, opts)
    if I.configured then
        return
    end
    I.configured = true

    local tools = vim.iter(vim.split(val, ",", { plain = true, trimempty = true }))
        :filter(function(v)
            return v ~= ""
        end)
        :totable()
    for _, tool in ipairs(tools) do
        local enabled = tool:sub(1, 1) ~= "!"
        local name = tool:sub(enabled and 1 or 2)
        vim.lsp.config(name, { enabled = enabled })
        I.opts.clients = I.opts.clients or {}
        I.opts.clients[name] = I.opts.clients[name] or {}
        I.opts.clients[name].enabled = enabled
    end

    -- Delaying this to make because vim.lsp.enable will trigger FileType events
    -- which might interfere with the currently running FileType event and
    -- break Treesitter
    utils.run.later(function()
        local to_enable = {}
        for name, _ in pairs(I.opts.clients) do
            local cfg = vim.lsp.config[name] --[[@as ide.Lsp.Client]]
            if cfg.enabled ~= false then
                if type(cfg.cmd) == "function" then
                    -- If cmd is a function it might require params so not resolving the binary
                    table.insert(to_enable, name)
                elseif cfg.cmd then
                    cfg.bin = type(cfg.bin) == "function" and cfg.bin() or cfg.bin
                    if type(cfg.cmd) == "table" and cfg.bin then
                        cfg.cmd[1] = cfg.bin --[[@as string]]
                        vim.lsp.config(name, { cmd = cfg.cmd, bin = cfg.bin })
                    end
                    local can_run, binary = utils.run.can_run_command(cfg.cmd)
                    if can_run then
                        -- If runnable directly then enable the client
                        table.insert(to_enable, name)
                    elseif vim.fn.executable("nix") then
                        -- If not runnable directly use Nix to run it
                        local nix_pkg = cfg.nix_pkg or binary
                        utils.run.get_nix_cmd({ pkg = nix_pkg, program = binary }, function(nix_cmd, o)
                            if o.code == 0 then
                                assert(type(cfg.cmd) ~= "function", "`cmd` should not be a function")
                                local cmd = cfg.cmd --[[@as table<string>]]

                                if type(cmd) == "table" and #cmd > 0 then
                                    table.remove(cmd, 1)
                                    vim.lsp.config(name, { cmd = vim.list_extend(nix_cmd, cmd), bin = cfg.bin })
                                    vim.lsp.enable(name)
                                end
                            end
                        end)
                    end
                end
            end
        end
        vim.lsp.enable(to_enable)
    end)
end

return M

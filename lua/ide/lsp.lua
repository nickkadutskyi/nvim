local utils = require("ide.utils")
local pack = require("ide.pack")

-- TODO: add ability to jump to a file path in PHP files provided as __DIR__."/path/to/file"
-- TODO: switch from fzf-lua to quick list for go to definition selection, also see
--       https://www.reddit.com/r/neovim/comments/1fhy2xi/how_switch_between_references_like_theprimeagen/

--- MODULE DEFINITION ----------------------------------------------------------
local M = {}
local I = {}

---@type ide.Opts.Lsp
I.opts = {}
I.configured = false
I.autocmdid = nil
I.setup = false

---@param opts ide.Opts.Lsp
function M.setup(opts)
    if I.setup then
        vim.notify("LSP already setup, skipping", vim.log.levels.WARN, { title = "ide.Lsp" })
        return
    end
    I.setup = true
    I.opts = opts or {}
    I.opts.clients = I.opts.clients or {}
    require("editorconfig").properties.tools_lsp = I.handle_tools_lsp_declaration
    I.configure_lsp_clients(opts.clients)
    I.feature_highlight_word_references()
    I.feature_show_color()

    -- In case we don't have tools_lsp in .editorconfig we still want to configure LSP clients
    -- Running this delayed to ensure we create our autocmd for BufReadPost
    -- after the one created by editorconfig.lua plugin
    -- utils.run.now_if_arg_or_later(function()
    -- Or run the whole setup process delayed. Currently pack spec will run after hook on BufReadPre
    I.autocmdid = utils.autocmd.create("BufReadPost", {
        group = "ide-lsp",
        callback = function(e)
            vim.api.nvim_del_autocmd(I.autocmdid)
            if I.configured then
                return
            end

            I.handle_tools_lsp_declaration(e.buf, "", {})
        end,
    })
    -- end)
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
                    cfg.bin = (type(cfg.bin) == "function" and { cfg.bin() } or { cfg.bin })[1]
                    if type(cfg.cmd) == "table" and type(cfg.bin) == "string" then
                        cfg.cmd[1] = cfg.bin --[[@as string]]
                        vim.lsp.config(name, { cmd = cfg.cmd, bin = cfg.bin })
                    elseif cfg.bin and type(cfg.bin) ~= "string" then
                        vim.notify(
                            "LSP client '" .. name .. "' has a non-string 'bin' field.",
                            vim.log.levels.WARN,
                            { title = "ide.Lsp" }
                        )
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

function I.feature_show_color()
    utils.run.on_lsp_attach(function(buf, client)
        if client and client:supports_method("textDocument/documentColor") then
            vim.lsp.document_color.enable(true, { bufnr = buf }, { style = "virtual" })
        end
    end, "ide.lsp: failed to attach to client for color highlighting")
end

-- The following two autocommands are used to highlight references of the
-- word under your cursor when your cursor rests there for a little while.
-- When you move your cursor, the highlights will be cleared (the second autocommand).
function I.feature_highlight_word_references()
    utils.run.on_lsp_attach(function(buf, client)
        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, buf) then
            local default_handler = vim.lsp.handlers["textDocument/documentHighlight"]

            -- Looks for line numbers of the highlighted references and stores them in a global variable
            -- For scrollbar marks to show up
            client.handlers["textDocument/documentHighlight"] = function(err, result, ctx, config)
                if result and #result > 0 then
                    local lines_set = {}
                    for _, highlight in ipairs(result) do
                        local range = highlight.range
                        local start_line = range.start.line + 1 -- Convert to 1-based
                        local end_line = range["end"].line + 1
                        for line = start_line, end_line do
                            -- lines_set[line] = true
                            table.insert(lines_set, { line = line, type = "IdentifierUnderCaret", level = 0 })
                        end
                    end
                    -- local lines = vim.tbl_keys(lines_set)
                    -- table.sort(lines)
                    vim.g.highlighted_lines = lines_set
                else
                    vim.g.highlighted_lines = {}
                end
                if pack.is_loaded("nvim-scrollbar") then
                    require("scrollbar.handlers").show()
                    require("scrollbar").throttled_render()
                end
                default_handler(err, result, ctx, config)
            end

            local hi_augroup = vim.api.nvim_create_augroup("ide-lsp-highlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                buffer = buf,
                group = hi_augroup,
                callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                buffer = buf,
                group = hi_augroup,
                callback = function()
                    vim.lsp.buf.clear_references()
                    vim.g.highlighted_lines = {}
                end,
            })

            vim.api.nvim_create_autocmd("LspDetach", {
                group = vim.api.nvim_create_augroup("ide-lsp-detach", { clear = true }),
                callback = function(event)
                    vim.g.highlighted_lines = {}
                    vim.lsp.buf.clear_references()
                    vim.api.nvim_clear_autocmds({
                        group = "ide-lsp-highlight",
                        buffer = event.buf,
                    })
                end,
            })
        end
    end)
end

return M

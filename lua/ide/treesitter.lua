local utils = require("ide.utils")

--- MODULE DEFINITION ----------------------------------------------------------

---@class ide.Utils.Plugins.Treesitter
local M = {}
local I = {}

---@param parsers ide.Opts.Treesitter
function M.ensure_installed(parsers)
    local ts = require("nvim-treesitter")
    local ts_config = require("nvim-treesitter.config")

    local already_installed = ts_config.get_installed("parsers")
    local parsers_to_install = vim.iter(parsers)
        :filter(function(parser)
            return not vim.tbl_contains(already_installed, parser)
        end)
        :totable()

    if #parsers_to_install > 0 then
        ts.install(parsers_to_install)
    end
end

---@param opts ide.Opts.Treesitter
function M.create_auto_start_autocmd(opts)
    utils.autocmd.create("FileType", {
        desc = "Auto start treesitter and install missing parsers",
        group = "ide.treesitter.auto_install",
        callback = function(ev)
            local ts_config = require("nvim-treesitter.config")

            local bufnr = ev.buf
            local filetype = ev.match

            local parser_name = I.get_parser_for_filetype(filetype, opts.syntax_map)
            if not parser_name or not vim.tbl_contains(ts_config.get_available(), parser_name) then
                return
            end

            if not I.is_installed(parser_name) then
                if opts.auto_install then
                    I.install_parser(parser_name, opts.sync_install, function()
                        I.start_treesitter(bufnr, parser_name, opts)
                    end)
                end
                return
            end

            I.start_treesitter(bufnr, parser_name, opts)
        end,
    })
end

---@param custom_parsers? table<string, ide.ParserInfo>
function M.setup_custom_parsers(custom_parsers)
    if not custom_parsers then
        return
    end
    utils.autocmd.create("User", {
        pattern = "TSUpdate",
        callback = function()
            for k, v in pairs(custom_parsers) do
                require("nvim-treesitter.parsers")[k] = v
                if v.filetypes then
                    vim.treesitter.language.register(k, v.filetypes)
                end
            end
        end,
    })
end

--- INTERNAL FUNCTIONS ---------------------------------------------------------

---@param parser string
---@return boolean
function I.is_installed(parser)
    local ts_config = require("nvim-treesitter.config")

    local installed_parsers = ts_config.get_installed("parsers")

    -- Check if parser is already installed
    return vim.tbl_contains(installed_parsers, parser)
end

---@param parser_name string
---@param sync boolean whether to install synchronously (blocking) or asynchronously (non-blocking)
---@param on_ready fun() callback to run after installation is complete (only used for async install
function I.install_parser(parser_name, sync, on_ready)
    local ts = require("nvim-treesitter")

    vim.notify("Installing parser for " .. parser_name, vim.log.levels.INFO, { title = "ide.utils.treesitter" })
    if sync == true then
        ts.install({ parser_name })
        vim.defer_fn(function()
            if type(on_ready) == "function" then
                on_ready()
            end
        end, 5000)
    else
        ts.install({ parser_name }):await(function()
            if type(on_ready) == "function" then
                on_ready()
            end
        end)
    end
end

---@param filetype string
---@param syntax_map table<string, string>
---@return string? parser name or nil if no parser found
function I.get_parser_for_filetype(filetype, syntax_map)
    -- Skip if no filetype
    if filetype == "" then
        return nil
    end

    -- Get parser name based on filetype
    local lang = vim.tbl_get(syntax_map, filetype)
    if lang == nil then
        lang = filetype
    else
        vim.notify("Using language override " .. lang, vim.log.levels.INFO, { title = "ide.utils.treesitter" })
    end

    local parser_name = vim.treesitter.language.get_lang(lang)
    if not parser_name then
        vim.notify(
            "No treesitter parser found for filetype: " .. lang,
            vim.log.levels.WARN,
            { title = "ide.utils.treesitter" }
        )
        return nil
    end

    return parser_name
end

---@param bufnr number
---@param parser_name string
---@param opts ide.Opts.Treesitter
function I.start_treesitter(bufnr, parser_name, opts)
    if opts.highlight.enable then
        vim.treesitter.start(bufnr, parser_name)
        -- Use regex based syntax-highlighting as fallback as some plugins might need it
        -- vim.bo[bufnr].syntax = "ON"
    end
    -- Use treesitter for folds
    vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.wo.foldtext = "v:lua.vim.treesitter.foldtext()"

    if opts.indent.enable then
        -- Use treesitter for indentation
        -- vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
end

return M

-- Gets exclude patterns from environment variable `FZFLUA_EXCLUDE`
local fzf_colors_switch = {
    [true] = {
        true,
        ["list-bg"] = { "bg", "WindowBackgroundShowExcluded" },
        ["bg"] = { "bg", "WindowBackgroundShowExcluded" },
        ["pointer"] = { "bg", "WindowBackgroundShowExcluded" },
        ["gutter"] = { "bg", "WindowBackgroundShowExcluded" },
    },
    [false] = true,
}

-- Helper function to resume FZF operation with updated options
local function resume_fzf_with_opts(show_excluded, opts)
    local options = vim.tbl_deep_extend("keep", {
        resume = true,
        fzf_colors = fzf_colors_switch[show_excluded],
    }, opts.__call_opts)
    opts.__call_fn(options)
end

local exclude_patterns = require("kdtsk.utils").parse_exclude_env("FZFLUA_EXCLUDE")
-- Cache the length to avoid recalculating in each iteration
local patterns_len = #exclude_patterns
local function is_excluded(item)
    -- Only check excluded patterns if exclusion is enabled and filename exists
    if item.filename then
        for i = 1, patterns_len do
            if item.filename:match(exclude_patterns[i]) then
                return true
            end
        end
    end

    return false
end
-- Configures LspAttach (on_attach) event for all language servers to set up keymaps
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("kdtsk-lsp-attach-keymap", { clear = true }),
    callback = function(event)
        local client = vim.lsp.get_client_by_id(event.data.client_id)

        -- The following two autocommands are used to highlight references of the
        -- word under your cursor when your cursor rests there for a little while.
        -- When you move your cursor, the highlights will be cleared (the second autocommand).
        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
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
                require("scrollbar.handlers").show()
                require("scrollbar").throttled_render()
                default_handler(err, result, ctx, config)
            end

            local hi_augroup = vim.api.nvim_create_augroup("kdtsk-lsp-highlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                buffer = event.buf,
                group = hi_augroup,
                callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                buffer = event.buf,
                group = hi_augroup,
                callback = function()
                    vim.lsp.buf.clear_references()
                    vim.g.highlighted_lines = {}
                end,
            })

            vim.api.nvim_create_autocmd("LspDetach", {
                group = vim.api.nvim_create_augroup("kdtsk-lsp-detach", { clear = true }),
                callback = function(event2)
                    vim.g.highlighted_lines = {}
                    vim.lsp.buf.clear_references()
                    vim.api.nvim_clear_autocmds({
                        group = "kdtsk-lsp-highlight",
                        buffer = event2.buf,
                    })
                end,
            })
        end

        -- The following code creates a keymap to toggle inlay hints in your
        -- code, if the language server you are using supports them
        if
            client
            and (
                client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint)
                or client.server_capabilities.inlayHintProvider
            )
        then
            vim.keymap.set("n", "<localleader>th", function()
                local new_state = not vim.lsp.inlay_hint.is_enabled({
                    bufnr = event.buf,
                })
                vim.lsp.inlay_hint.enable(new_state, {
                    bufnr = event.buf,
                })
            end, { buffer = event.buf, desc = "LSP: [t]oggle inlay [h]ints" })
        end

        if client and client:supports_method("textDocument/documentColor") then
            vim.lsp.document_color.enable(true, event.buf, {
                style = "virtual",
            })
        end
    end,
})

---@type LazySpec
return {
    { -- Uses LSP to show current code context—used in status line
        "SmiteshP/nvim-navic",
        event = "VeryLazy",
        ---@type Options
        opts = {
            depth_limit = 4,
            highlight = true,
            color_correction = "dynamic",
            lsp = {
                auto_attach = true,
                preference = {
                    "phpactor", -- TODO: find a way to switch to intelephense
                    "nixd", -- Works better than nil_ls
                },
            },
            format_text = function(text)
                -- This is a workaround for the fact that `nixd` returns
                -- `{anonymous}` as the name of Array kind
                if text == "{anonymous}" then
                    return "{a}"
                end
                local len = #text
                local goal_len = 30
                if len <= goal_len then
                    return text
                else
                    local middle_len = 2 -- Length of ".."
                    local left_len = math.floor((goal_len - middle_len) * 0.7)
                    local right_len = goal_len - middle_len - left_len
                    return text:sub(1, left_len) .. ".." .. text:sub(len - right_len + 1, len)
                end
            end,
        },
        ---@param opts Options
        config = function(_, opts)
            local navic = require("nvim-navic")

            -- Adjusts icon for JSON objects
            local format_data = function(data, opts_internal)
                if vim.bo.filetype == "json" then
                    for _, item in ipairs(data) do
                        if item.type == "Module" then
                            item.type = "Object"
                            item.kind = 19
                        end
                    end
                end
                return data
            end
            navic.get_location = function(opts_internal, bufnr)
                local data = navic.get_data(bufnr)
                data = format_data(data, opts_internal)
                return navic.format_data(data, opts_internal)
            end

            -- Sets icons from jb.nvim
            opts.icons = vim.tbl_map(function(icon)
                return icon ~= "" and icon .. " " or ""
            end, Utils.icons.kind)

            navic.setup(opts)
        end,
    },
}

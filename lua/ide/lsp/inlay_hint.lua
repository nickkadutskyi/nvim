local M = {}

local prefix = ""
local suffix = ""

function M.setup()
    require("vim.lsp.inlay_hint")
    local inlay_hint = require("vim.lsp._capability").all.inlay_hint
    if inlay_hint.pill_renderer then
        return
    end
    inlay_hint.pill_renderer = true

    function inlay_hint:on_win(topline, botline)
        local api = vim.api
        local buf_versions = require("vim.lsp.util").buf_versions

        for _, state in pairs(self.client_state) do
            local current_result = state.current_result
            if current_result.version == buf_versions[self.bufnr] then
                if not current_result.namespace_cleared then
                    api.nvim_buf_clear_namespace(self.bufnr, state.namespace, 0, -1)
                    current_result.namespace_cleared = true
                end

                local hints = assert(current_result.hints)
                for lnum = topline, botline do
                    local hint_virtual_texts = {}
                    local line_hints = hints[lnum]
                    if line_hints and not line_hints.applied then
                        line_hints.applied = true
                        for _, hint in pairs(line_hints.hints) do
                            local label = hint.label
                            local text = type(label) == "string" and label
                                or vim.iter(label)
                                    :map(function(part)
                                        return part.value
                                    end)
                                    :join("")
                            local virtual_text = hint_virtual_texts[hint.position.character] or {}

                            -- if hint.paddingLeft then
                            --     virtual_text[#virtual_text + 1] = { " " }
                            -- end
                            virtual_text[#virtual_text + 1] = { prefix, "LspInlayHintReverse" }
                            virtual_text[#virtual_text + 1] = { text, "LspInlayHint" }
                            virtual_text[#virtual_text + 1] = { suffix, "LspInlayHintReverse" }
                            -- if hint.paddingRight then
                            --     virtual_text[#virtual_text + 1] = { " " }
                            -- end

                            hint_virtual_texts[hint.position.character] = virtual_text
                        end
                    end

                    for position, virtual_text in pairs(hint_virtual_texts) do
                        api.nvim_buf_set_extmark(self.bufnr, state.namespace, lnum, position, {
                            virt_text_pos = "inline",
                            ephemeral = false,
                            virt_text = virtual_text,
                        })
                    end
                end
            end
        end
    end
end

return M

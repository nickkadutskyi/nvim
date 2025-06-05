local handler = function(virtText, lnum, endLnum, width, truncate)
    local newVirtText = {}
    local suffix = (" 󰁂 %d "):format(endLnum - lnum)
    local sufWidth = vim.fn.strdisplaywidth(suffix)
    local targetWidth = width - sufWidth
    local curWidth = 0
    for _, chunk in ipairs(virtText) do
        local chunkText = chunk[1]
        local chunkWidth = vim.fn.strdisplaywidth(chunkText)
        if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
        else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            -- str width returned from truncate() may less than 2nd argument, need padding
            if curWidth + chunkWidth < targetWidth then
                suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
            end
            break
        end
        curWidth = curWidth + chunkWidth
    end
    table.insert(newVirtText, { suffix, "MoreMsg" })
    return newVirtText
end

---@param bufnr number
---@return Promise
local function customizeSelector(bufnr)
    local function handleFallbackException(err, providerName)
        if type(err) == "string" and err:match("UfoFallbackException") then
            return require("ufo").getFolds(bufnr, providerName)
        else
            return require("promise").reject(err)
        end
    end

    return require("ufo")
        .getFolds(bufnr, "lsp")
        :catch(function(err)
            return handleFallbackException(err, "treesitter")
        end)
        :catch(function(err)
            return handleFallbackException(err, "indent")
        end)
end

---@type LazySpec
return {
    {
        "kevinhwang91/nvim-ufo",
        dependencies = "kevinhwang91/promise-async",
        enabled = true,
        config = function()
            -- Define folding method per filetype
            local ftMap = {
                vim = "indent",
                python = { "indent" },
                git = "",
                json = { "treesitter", "indent" },
                -- js = { "treesitter", "indent" },
                vue = { "treesitter", "indent" },
            }
            -- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
            vim.keymap.set("n", "zR", require("ufo").openAllFolds)
            vim.keymap.set("n", "zM", require("ufo").closeAllFolds)

            require("ufo").setup({
                open_fold_hl_timeout = 150,
                enable_get_fold_virt_text = true,
                fold_virt_text_handler = Utils.fold.ufo_virt_text_handler_one_line,
                close_fold_kinds_for_ft = {
                    default = { "imports", "comment" },
                    json = { "array" },
                    c = { "comment", "region" },
                },
                provider_selector = function(bufnr, filetype, buftype)
                    return ftMap[filetype] or Utils.fold.ufo_provider_selector
                end,
            })
        end,
    },
}

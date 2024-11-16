-- This file is automatically loaded by Neovim before any filetype is detected
vim.filetype.add({
    extension = {
        -- Neon is a YAML-like language
        neon = "yaml",
        -- AppleScript or JavaScript for Automation (JXA)
        scpt = function(path, bufnr)
            local content = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] or ""
            if
                vim.regex([[^#!/usr/bin/osascript -l JavaScript]]):match_str(content) ~= nil
                or vim.regex([[^#!/usr/bin/env osascript -l JavaScript]]):match_str(content) ~= nil
            then
                return "javascript"
            else
                return "applescript"
            end
        end,
    },
    filename = {
        -- Config file for js-beautify
        -- (used by Intelephense https://github.com/bmewburn/vscode-intelephense/issues/729)
        [".jsbeautifyrc"] = "json",
    },
})

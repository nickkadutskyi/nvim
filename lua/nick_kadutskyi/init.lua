require("nick_kadutskyi.set")
require("nick_kadutskyi.remap")

-- if opened a dir set it as current dir to help narrow down telescope's scope
if vim.fn.isdirectory(vim.v.argv[2]) == 1 then
  vim.api.nvim_set_current_dir(vim.v.argv[2])
end

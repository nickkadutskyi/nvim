require("nick_kadutskyi.set")
require("nick_kadutskyi.remap")

-- if opened a dir set it as current dir to help narrow down telescope's scope
if vim.fn.isdirectory(vim.fn.expand('%')) == 1 then
  vim.api.nvim_set_current_dir(vim.fn.expand('%'))
else
  vim.api.nvim_set_current_dir(vim.fn.expand('%:p:h'))
end

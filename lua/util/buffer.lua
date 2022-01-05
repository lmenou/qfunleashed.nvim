local api, fn = vim.api, vim.fn
-- local M = {}

Create_buf = function()
  api.nvim_command [[topleft 10split UnleashedStatus]]
  vim.bo.bufhidden = 'hide'
  vim.bo.buftype = 'nofile'
  vim.bo.buflisted = true
  vim.bo.swapfile = false
  vim.wo.wrap = false
end

Create_buf()

-- return M

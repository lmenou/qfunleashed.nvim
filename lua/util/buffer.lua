local api, fn = vim.api, vim.fn
-- local M = {}

Create_buf = function()
  api.nvim_command [[topleft 10split UnleashedStatus]]
  vim.bo.bufhidden = 'hide'
  vim.bo.buftype = 'nofile'
  vim.bo.buflisted = true
  vim.bo.swapfile = false
  vim.wo.wrap = false
  return fn.getbufinfo(0).bufnr
end

Buf_set_lines = function()
  local bufnr = Create_buf()
  api.nvim_buf_set_option(bufnr, 'modifiable', true)
  api.nvim_buf_set_option(bufnr, 'readonly', false)
  api.nvim_buf_set_lines(bufnr, 0, -1, false, {})

  local lines = {
    "UnleashedStatus:",
    "  2 jobs are running",
    "",
    "Quickfix list:",
    "==Details==",
    "",
    "Location list:",
    "==Details==",
  }
  api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  api.nvim_buf_set_option(bufnr, 'modifiable', false)
  api.nvim_buf_set_option(bufnr, 'readonly', true)
end

Buf_set_lines()

-- return M

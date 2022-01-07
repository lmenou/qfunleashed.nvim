local api, fn = vim.api, vim.fn
local M = {}

local create_buf = function()
  api.nvim_command [[topleft 20split UnleashedStatus]]

  vim.bo.bufhidden = 'hide'
  vim.bo.buflisted = true
  vim.bo.swapfile = false

  vim.wo.wrap = false
  vim.wo.winfixheight = true

  vim.api.nvim_command [[set filetype=unleashed]]
  return fn.getbufinfo(0).bufnr
end

local buffer_wipe = function(bufnr)
  api.nvim_buf_set_option(bufnr, 'modifiable', true)
  api.nvim_buf_set_option(bufnr, 'readonly', false)
  api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
end

local buffer_nonmodif = function(bufnr)
  api.nvim_buf_set_option(bufnr, 'modifiable', false)
  api.nvim_buf_set_option(bufnr, 'readonly', true)
  api.nvim_buf_set_option(bufnr, 'modified', false)
  api.nvim_buf_set_option(bufnr, 'buflisted', false)
end

M.buf_set_lines = function()
  local bufnr = create_buf()
  buffer_wipe(bufnr)

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

  buffer_nonmodif(bufnr)
end

return M

-- lua: et tw=79 ts=2 sts=2 sw=2

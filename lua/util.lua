local M = {}
local api = vim.api

M.echo_type = function(type, arg)
  local msg = string.format([[
  echohl %s
  echomsg "unleashed: %s"
  echohl NONE
  ]], type, arg)
  api.nvim_command(msg)
end

return M

-- lua: et tw=79 ts=2 sts=2 sw=2

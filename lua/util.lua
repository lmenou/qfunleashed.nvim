local M = {}
local api = vim.api

M.echo_type = function(type, arg)
  local msg = string.format(
    [[
  echohl %s
  echomsg "%s(unleashed): %s"
  echohl NONE
 ]],
    type,
    string.sub(type, 1, 1),
    arg
  )
  api.nvim_command(msg)
end

M.is_in_table = function(t, arg)
  for k, v in pairs(t) do
    if v == arg then
      return k, true
    end
  end
  return nil, false
end

return M

-- lua: et tw=79 ts=2 sts=2 sw=2

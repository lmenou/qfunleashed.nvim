local M = {}
local api = vim.api

M.echo_type = function(hlmode, arg)
  local msg = string.format(
    [[
  echohl %s
  echomsg "%s(unleashed): %s"
  echohl NONE
 ]],
    hlmode,
    string.sub(hlmode, 1, 1),
    arg
  )
  api.nvim_command(msg)
end

M.is_in_table = function(t, arg)
  if arg == nil then
    return 4, true
  else
    for k, v in pairs(t) do
      if v == arg then
        return k, true
      end
    end
  end

  return nil, false
end

M.first_word = function(sentence, delimiter)
  local result = {}
  for match in (sentence .. delimiter):gmatch("(.-)" .. delimiter) do
    table.insert(result, match)
  end
  return result[1]
end

return M

-- lua: et tw=79 ts=2 sts=2 sw=2

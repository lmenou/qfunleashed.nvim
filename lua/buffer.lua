local api, fn = vim.api, vim.fn

-- To operate on the buffer
local buf = {}

function buf:create_buf()
  api.nvim_command [[topleft 20split UnleashedStatus]]
  self.bufnr = fn.getbufinfo(0).bufnr

  api.nvim_buf_set_option(self.bufnr, "bufhidden", "hide")
  api.nvim_buf_set_option(self.bufnr, "buflisted", true)
  api.nvim_buf_set_option(self.bufnr, "swapfile", true)

  api.nvim_win_set_option(0, "wrap", true)
  api.nvim_win_set_option(0, "winfixheight", true)

  vim.api.nvim_command [[set filetype=unleashed]]
end

function buf:buffer_wipe()
  api.nvim_buf_set_option(self.bufnr, "modifiable", true)
  api.nvim_buf_set_option(self.bufnr, "readonly", false)
  api.nvim_buf_set_lines(self.bufnr, 0, -1, false, {})
end

function buf:buffer_nonmodif()
  api.nvim_buf_set_option(self.bufnr, "modifiable", false)
  api.nvim_buf_set_option(self.bufnr, "readonly", true)
  api.nvim_buf_set_option(self.bufnr, "modified", false)
  api.nvim_buf_set_option(self.bufnr, "buflisted", false)
end

function buf:buf_set_lines(t)
  if next(self) then
    self:create_buf()
  end
  buf:buffer_wipe()

  if t.set_lines then
    local lines = t.set_lines
    api.nvim_buf_set_lines(self.bufnr, 0, -1, false, lines)
  end

  self:buffer_nonmodif()
end

return buf

-- lua: et tw=79 ts=2 sts=2 sw=2

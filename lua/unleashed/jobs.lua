local util = require "unleashed"
local fn, api = vim.fn, vim.api

local Jobs = {}

function Jobs:new(t)
  t = t or {}
  self.__index = self
  t = setmetatable(t, self)
  return t
end

-- [[ MESSAGER AT THE END OF THE PROCESS ]]
function Jobs:messager(msg)
  local final_msg
  if self.first == 1 then
    final_msg = string.format(msg .. " (1 of %s): %s", self.non_nil[1], self.non_nil[2])
  else
    final_msg = string.format(msg .. " (%s items)", self.non_nil[1])
  end
  return final_msg
end

-- [[ GET THE ASYNC PRG PROPERTIES ]]
-- NOTE: It seems that the expansion is already taken care of
function Jobs:get_makeprg(arg)
  local makeprg = vim.o.makeprg

  self.makeprg = makeprg .. " " .. arg
end

function Jobs:get_grepprg(arg)
  local grepprg = vim.o.grepprg

  if string.find(grepprg, "%$%*") then
    grepprg = string.gsub(grepprg, "%$%*", arg)
  else
    grepprg = grepprg .. " " .. arg
  end
  self.grepprg = grepprg
end

function Jobs:get_findprg(arg)
  local findprg = vim.g.qfunleashed_findprg

  if string.find(findprg, "%$%*") then
    findprg = string.gsub(findprg, "%$%*", arg)
  else
    findprg = findprg .. " " .. arg
  end
  self.findprg = findprg
end

-- [[ SETTER FOR QUICKFIX AND LOCATION LIST ]]
function Jobs:quickfix_setter()
  local opts = {}
  if self.type == "make" then
    opts.title = self.makeprg
    opts.efm = self.errorformat
  elseif self.type == "grep" then
    opts.title = self.grepprg
    opts.efm = self.grepformat
  else
    opts.title = self.findprg
    opts.efm = self.grepformat
  end
  opts.lines = api.nvim_buf_get_lines(self.scratch_buf_id, 0, -2, false)
  if opts.lines[1] and opts.lines[1] ~= "" then
    self.non_nil = { #opts.lines, string.gsub(opts.lines[1], '"', '\\"') }
  end
  if self.adding == 0 then
    fn.setqflist({}, " ", opts)
  else
    opts.nr = 0
    fn.setqflist({}, "a", opts)
  end
end

function Jobs:location_setter()
  local opts = {}
  if self.type == "make" then
    opts.title = self.makeprg
    opts.efm = self.errorformat
  elseif self.type == "grep" then
    opts.title = self.grepprg
    opts.efm = self.grepformat
  else
    opts.title = self.findprg
    opts.efm = self.grepformat
  end
  opts.lines = api.nvim_buf_get_lines(self.scratch_buf_id, 0, -2, false)
  if opts.lines[1] and opts.lines[1] ~= "" then
    self.non_nil = { #opts.lines, string.gsub(opts.lines[1], '"', '\\"') }
  end
  if self.adding == 0 then
    fn.setloclist(0, {}, " ", opts)
  else
    opts.nr = 0
    fn.setloclist(0, {}, "a", opts)
  end
end

-- [[ OUTER FOR QUICKFIX LIST AND LOCATION LIST ]]
function Jobs:quickfix_out()
  local msg

  if self.non_nil then
    if self.first == 1 then
      api.nvim_command [[ silent! cfirst ]]
    end
    if vim.g.qfunleashed_quick_open == 1 then
      api.nvim_command [[ silent copen | wincmd p ]]
    end
    if self.type == "grep" then
      msg = "Grep succeeded"
    elseif self.type == "make" then
      msg = "Build failed"
    else
      msg = "Find successful"
    end
    local hlmode = (self.type == "find" or self.type == "grep") and "MoreMsg" or "WarningMsg"
    msg = self:messager(msg)
    util.echo_type(hlmode, msg)
  else
    if vim.g.qfunleashed_quick_open == 1 then
      api.nvim_command [[ silent! cclose ]]
    end
    if self.type == "grep" then
      msg = "Grep empty"
    elseif self.type == "make" then
      msg = "Build successful"
    else
      msg = "Find empty"
    end
    util.echo_type("MoreMsg", msg)
  end
end

function Jobs:location_out()
  local msg

  if self.non_nil then
    if self.first == 1 then
      api.nvim_command [[ silent! lfirst ]]
    end
    if vim.g.qfunleashed_quick_open == 1 then
      api.nvim_command [[ silent lopen | wincmd p ]]
    end
    if self.type == "grep" then
      msg = "Grep succeded"
    elseif self.type == "make" then
      msg = "Build failed"
    else
      msg = "Find successful"
    end
    local hlmode = (self.type == "find" or self.type == "grep") and "MoreMsg" or "WarningMsg"
    msg = self:messager(msg)
    util.echo_type(hlmode, msg)
  else
    if vim.g.qfunleashed_quick_open == 1 then
      api.nvim_command [[ silent! lclose ]]
    end
    if self.type == "grep" then
      msg = "Grep empty"
    elseif self.type == "make" then
      msg = "Build successful"
    else
      msg = "Find empty"
    end
    util.echo_type("MoreMsg", msg)
  end
end

function Jobs:create_buffer()
  local scratch_buf_id = api.nvim_create_buf(false, true)
  api.nvim_buf_set_option(scratch_buf_id, "modifiable", false)
  api.nvim_buf_set_option(scratch_buf_id, "readonly", true)
  self.scratch_buf_id = scratch_buf_id
end

function Jobs:write_lines(data)
  local buf_id = self.scratch_buf_id
  api.nvim_buf_set_option(buf_id, "modifiable", true)
  api.nvim_buf_set_option(buf_id, "readonly", false)
  api.nvim_buf_set_lines(buf_id, -2, -1, false, data)
  api.nvim_buf_set_option(buf_id, "modifiable", false)
  api.nvim_buf_set_option(buf_id, "readonly", true)
end

function Jobs:create_window()
  api.nvim_command "topleft 20split"
  local win_id = fn.win_getid()
  api.nvim_command "wincmd p"
  api.nvim_win_set_option(win_id, "winfixheight", true)
  api.nvim_win_set_buf(win_id, self.scratch_buf_id)
  self.win_id = win_id
end

return Jobs

-- lua: et tw=79 ts=2 sts=2 sw=2

local util = require "util"
local fn, api = vim.fn, vim.api

local Jobs = {}

function Jobs:new(t)
  t = t or {}
  self.__index = self
  t = setmetatable(t, self)
  return t
end

-- [[ GET THE ASYNC PRG PROPERTIES ]]
function Jobs:get_makeprg(arg)
  local makeprg = vim.o.makeprg

  self.makeprg = fn.expandcmd(makeprg .. " " .. arg)
end

function Jobs:get_grepprg(arg)
  local grepprg = vim.o.grepprg

  self.grepprg = fn.expandcmd(grepprg .. " " .. arg)
end

-- [[ SETTER FOR QUICKFIX AND LOCATION LIST ]]
function Jobs:quickfix_setter()
  local opts = {}
  if self.type == "make" then
    opts.title = self.makeprg
    opts.efm = self.errorformat
  else
    opts.title = self.grepprg
    opts.efm = self.grepformat
  end
  opts.lines = self.data
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
  else
    opts.title = self.grepprg
    opts.efm = self.grepformat
  end
  opts.lines = self.data
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

  if self.data[1] ~= nil then
    if self.first == 1 then
      api.nvim_command [[ silent! cfirst ]]
    end
    if vim.g.unleashed_build_quick_open == 1 then
      api.nvim_command [[ silent copen | wincmd p ]]
    end
    msg = self.type == "grep" and "Grep succeeded !" or "Build failed..."
    local hlmode = self.type == "grep" and "MoreMsg" or "WarningMsg"
    util.echo_type(hlmode, msg)
  else
    msg = self.type == "grep" and "Grep empty !" or "Build succeeded !"
    util.echo_type("MoreMsg", msg)
  end
end

function Jobs:location_out()
  local msg

  if self.data[1] ~= nil then
    if self.first == 1 then
      api.nvim_command [[ silent! lfirst ]]
    end
    if vim.g.unleashed_build_quick_open == 1 then
      api.nvim_command [[ silent lopen | wincmd p ]]
    end
    msg = self.type == "grep" and "Grep succeeded !" or "Build failed..."
    local hlmode = self.type == "grep" and "MoreMsg" or "WarningMsg"
    util.echo_type(hlmode, msg)
  else
    msg = self.type == "grep" and "Grep empty !" or "Build succeeded !"
    util.echo_type("MoreMsg", msg)
  end
end

return Jobs

-- lua: et tw=79 ts=2 sts=2 sw=2

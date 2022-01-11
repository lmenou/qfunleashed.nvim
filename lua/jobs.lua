local fn = vim.fn

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

return Jobs
-- lua: et tw=79 ts=2 sts=2 sw=2

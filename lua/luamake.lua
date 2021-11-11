local fn, api = vim.fn, vim.api

module = {}

local jobinfo = {
  location = {},
  quickfix = {},
}

jobinfo.quickfix.data = {}
jobinfo.location.data = {}

 -- [[ TO KNOW ON WHICH JOB TO ACT ]]
function jobinfo.get_jobid_pos(self, job_id)
  if self.quickfix.jobid == job_id then
    return "quickfix"
  else
    return "location"
  end
end

-- [[ GET THE ASYNC PRG PROPERTIES ]]
function jobinfo.get_makeprg(self, arg, pos)
  local makeprg = vim.o.makeprg

  self[pos].makeprg = fn.expandcmd(makeprg .. " " .. arg)
end

function jobinfo.get_grepprg(self, arg, pos)
  local grepprg = vim.o.grepprg

  self[pos].grepprg = fn.expandcmd(grepprg .. " " .. arg)
end

-- [[ SETTER FOR QUICKFIX AND LOCATION LIST ]]
function jobinfo.quickfix_setter(self)
  local opts = {}
  if self.quickfix.name == "make" then
    opts.title = self.quickfix.makeprg
    opts.efm = self.quickfix.errorformat
  else
    opts.title = self.quickfix.grepprg
    opts.efm = self.quickfix.grepformat
  end
  opts.lines = self.quickfix.data
  if self.quickfix.adding == false then
    fn.setqflist({}, " ", opts)
  else
    opts.nr = 0
    fn.setqflist({}, "a", opts)
  end
end

function jobinfo.location_setter(self)
  local opts = {}
  if self.location.name == "make" then
    opts.title = self.location.makeprg
    opts.efm = self.location.errorformat
  else
    opts.title = self.location.grepprg
    opts.efm = self.location.grepformat
  end
  opts.lines = self.location.data
  if self.location.adding == false then
    fn.setloclist(0, {}, " ", opts)
  else
    opts.nr = 0
    fn.setloclist(0, {}, "a", opts)
  end
end

-- [[ HANDLER ]]
local function handler(job_id, data, event)
  -- To know on which job to act
  local index = jobinfo:get_jobid_pos(job_id)

  if event == "stdout" or event == "stderr" then
    for k, v in pairs(data) do
      if v == "" then
        data[k] = nil
      end
    end
    vim.list_extend(jobinfo[index].data, data)
  end

  if event == "exit" then
    if jobinfo[index].stop_job then
      print("Job(s) has(ve) been stopped.")
    else
      if index == "quickfix" then
        jobinfo:quickfix_setter()
        if jobinfo.quickfix.first == true and jobinfo.quickfix.data[1] ~= nil then
          api.nvim_command [[silent! cfirst]]
        end
        if vim.g.luamake_quick_open == 1 then
          api.nvim_command [[copen | wincmd p]]
        end
      else
        jobinfo:location_setter()
        if jobinfo.location.first == true and jobinfo.location.data[1] ~= nil then
          api.nvim_command [[silent! lfirst]]
        end
        if vim.g.luamake_quick_open == 1 then
          api.nvim_command [[lopen | wincmd p]]
        end
      end
    end
    jobinfo[index].data = {}
    jobinfo[index].stop_job = false
    jobinfo[index].name = nil
    jobinfo[index].jobid = nil
  end
end

-- [[ THE PLUGIN ITSELF ]]
function module.completion()
  local rtn = "quickfix\nlocation\nall"
  return rtn
end

function module.stop_job(arg)
  local jobstop
  if arg == nil or arg == "all" then
    if jobinfo.quickfix.jobid == nil and jobinfo.location.jobid == nil then
      print("No jobs are running, keep moving on...")
    else
      jobinfo.quickfix.stop_job = true
      jobstop = fn.jobstop(jobinfo.quickfix.jobid)
      if not jobstop then
        print("Quickfix jobId is not valid, failed to stop the job.")
      end
      jobinfo.location.stop_job = true
      jobstop = fn.jobstop(jobinfo.location.jobid)
      if not jobstop then
        print("Location jobId is not valid, failed to stop the job.")
      end
    end
  else
    if not (arg:match("location") or arg:match("quickfix")) then
      print("Given argument is not valid !")
    else
      if jobinfo[arg].jobid == nil then
        print("No job is running here, keep moving on...")
      else
        jobinfo[arg].stop_job = true
        jobstop = fn.jobstop(jobinfo[arg].jobid)
        if not jobstop then
          print("arg .. jobId is not valid, failed to stop the job.")
        end
      end
    end
  end
end

function module.ajob(arg, grep, loc, add, bang)

  local pos = loc == 1 and "location" or "quickfix"

  if grep == 0 then
    jobinfo:get_makeprg(arg, pos)
    jobinfo[pos].errorformat = vim.o.errorformat
    jobinfo[pos].name = "make"
  else
    jobinfo:get_grepprg(arg, pos)
    jobinfo[pos].grepformat = vim.o.grepformat
    jobinfo[pos].name = "grep"
  end

  if bang == "!" then
    jobinfo[pos].first = false
  else
    jobinfo[pos].first = true
  end

  jobinfo[pos].adding = add == 1 and true or false

  local opts = {
    on_stderr = handler,
    on_stdout = handler,
    on_exit = handler,
    stderr_buffered = false,
    stdout_buffered = false
  }

  api.nvim_command [[doautocmd QuickFixCmdPre]]

  if grep == 0 then
    jobinfo[pos].jobid = fn.jobstart(jobinfo[pos].makeprg, opts)
  else
    jobinfo[pos].jobid = fn.jobstart(jobinfo[pos].grepprg, opts)
  end
end

return module

-- lua: et tw=79 ts=2 sts=2 sw=2

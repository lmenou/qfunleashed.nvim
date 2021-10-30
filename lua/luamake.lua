local fn, api = vim.fn, vim.api

module = {}

jobinfo = {
  location = {},
  quickfix = {},
}

jobinfo.quickfix.data = {}
jobinfo.location.data = {}

 -- [[ TO KNOW ON WHICH JOB TO ACT ]]
local function get_jobid_pos(jobinfo, job_id)
  for k, v in pairs(jobinfo) do
    if v.jobid == job_id then
      return k
    end
  end
end

 -- [[ GET OPTIONS REGARDING MAKE AND GREP ]]
local function get_makeprg(arg, winnr, bufnr, pos)
  local function get_buf_makeprg() 
    return api.nvim_buf_get_option(bufnr, 'makeprg') 
  end

  local makeprg
  if pcall(get_buf_makeprg) then
    makeprg = get_buf_makeprg()
  else
    makeprg = vim.api.nvim_get_option('makeprg')
  end

  makeprg = makeprg .. " " .. arg
  makeprg = vim.fn.expandcmd(makeprg)

  jobinfo[pos]["makeprg"] = makeprg
end

local function get_grepprg(arg, winnr, bufnr, pos)
  local function get_buf_grepprg()
    return api.nvim_buf_get_option(bufnr, 'grepprg')
  end

  local grepprg
  if pcall(get_buf_grepprg) then
    grepprg = get_buf_grepprg()
  else
    grepprg = api.nvim_get_option('grepprg')
  end

  grepprg = grepprg .. " " .. arg
  grepprg = fn.expandcmd(grepprg)

  jobinfo[pos]["grepprg"] = grepprg
end

local function get_errorformat(winnr, bufnr, pos)
  local function get_buf_efm()
    return api.nvim_buf_get_option(bufnr, 'errorformat')
  end

  local efm
  if pcall(get_buf_efm) then
    efm = get_buf_efm()
  else
    efm = api.nvim_get_option('errorformat')
  end

  jobinfo[pos]["errorformat"] = efm
end

local function get_grepformat(winnr, bufnr, pos)
  local function get_buf_grepfmt()
    return api.nvim_buf_get_option(bufnr, 'grepformat')
  end

  local grepfmt
  if pcall(get_buf_grepfmt) then
    grepfmt = get_buf_grepfmt()
  else
    grepfmt = api.nvim_get_option('grepformat')
  end

  jobinfo[pos]["grepformat"] = grepfmt
end

-- [[ SETTER FOR QUICKFIX AND LOCATION LIST ]]
local function quickfix_setter(jobinfo)
  local opts = {}
  if jobinfo.quickfix.name == "make" then
    opts.title = jobinfo.quickfix.makeprg
    opts.efm = jobinfo.quickfix.errorformat
  else
    opts.title = jobinfo.quickfix.grepprg
    opts.efm = jobinfo.quickfix.grepformat
  end
  opts.lines = jobinfo.quickfix.data
  if jobinfo.quickfix.adding == false then
    fn.setqflist({}, " ", opts)
  else
    opts.nr = 0
    fn.setqflist({}, "a", opts)
  end
end

local function location_setter()
  local opts = {}
  if jobinfo.location.name == "make" then
    opts.title = jobinfo.location.makeprg
    opts.efm = jobinfo.location.errorformat
  else
    opts.title = jobinfo.location.grepprg
    opts.efm = jobinfo.location.grepformat
  end
  opts.lines = jobinfo.location.data
  if jobinfo.location.adding == false then
    fn.setloclist(0, {}, " ", opts)
  else
    opts.nr = 0
    fn.setloclist(0, {}, "a", opts)
  end
end

-- [[ HANDLER ]]
local function handler(job_id, data, event)
  -- To know on which job to act
  local index = get_jobid_pos(jobinfo, job_id)

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
        quickfix_setter(jobinfo)
        if jobinfo.quickfix.first == true and jobinfo.quickfix.data[1] ~= nil then
          api.nvim_command [[silent! cfirst]]
        end
        if quickopen then
          api.nvim_command [[copen | wincmd p]]
        end
      else
        location_setter(jobinfo)
        if jobinfo.location.first == true and jobinfo.location.data[1] ~= nil then
          api.nvim_command [[silent! lfirst]]
        end
        if quickopen then
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
function module.completion(arglead, cmdline, cursorpos)
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

  local winnr = fn.win_getid()
  local bufnr = api.nvim_win_get_buf(winnr)
  if grep == 0 then
    get_makeprg(arg, winnr, bufnr, pos)
    get_errorformat(winnr, bufnr, pos)
    jobinfo[pos].name = "make"
  else
    get_grepprg(arg, winnr, bufnr, pos)
    get_grepformat(winnr, bufnr, pos)
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

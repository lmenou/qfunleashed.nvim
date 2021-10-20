local fn, api = vim.fn, vim.api

module = {}

jobinfo = {
  location = {},
  quickfix = {},
}

jobinfo.location.data = {}
jobinfo.quickfix.data = {}

-- For plugin development

function module.reload()
  print("Plugin reloaded")
end

-- Plugin 

local function get_jobid_pos(jobinfo, job_id)
  for k, v in pairs(jobinfo) do
    if v.jobid == job_id then
      return k
    end
  end
end

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

local function handler(job_id, data, event)

  -- To know on which job to act
  local index = get_jobid_pos(jobinfo, job_id)

  if event == "stdout" or event == "stderr" then
    --[[ 
    From time to time data is an empty string
    I do not know why... 
    This is weird, I know
    --]]
    for k, v in pairs(data) do
      if v == "" then
        data[k] = nil
      end
    end
    -- End of the cleaning
    -- Enable a better parsing ?
    vim.list_extend(jobinfo[index]["data"], data)
  end

  if event == "exit" then
    if jobinfo[index].stop_job then
      print("Job(s) has(ve) been stopped.")
      jobinfo[index]["data"] = {}
      jobinfo[index].stop_job = false
      jobinfo[index].name = nil
    else
      local opts
      if jobinfo[index]["name"] == "make" then
        opts = {
          title = jobinfo[index]["makeprg"],
          lines = jobinfo[index]["data"],
          efm = jobinfo[index]["errorformat"]
        }
      else
        opts = {
          title = jobinfo[index]["grepprg"],
          lines = jobinfo[index]["data"],
          efm = jobinfo[index]["grepformat"]
        }
      end
      jobinfo[index].name = nil
      -- TODO: Need to optimize this !!!
      if jobinfo[index].adding == false then
        if index == "quickfix" then
          fn.setqflist({}, " ", opts)
        else
          fn.setloclist(0, {}, " ", opts)
        end
      else
        opts.nr = 0
        if index == "quickfix" then
          fn.setqflist({}, "a", opts)
        else
          fn.setloclist(0, {}, "a", opts)
        end
      end
      api.nvim_command [[doautocmd QuickFixCmdPost]]
      if quickopen then
        if index == "quickfix" then
          api.nvim_command [[copen]]
          api.nvim_command [[wincmd k]]
          if jobinfo[index].first == true and jobinfo[index]["data"][1] ~= "" then
            api.nvim_command [[silent! cfirst]]
          end
        else
          api.nvim_command [[lopen]]
          api.nvim_command [[wincmd k]]
          if jobinfo[index].first == true and jobinfo[index]["data"][1] ~= "" then
            api.nvim_command [[silent! lfirst]]
          end
        end
      else
        print("Job is done.")
        if index == "quickfix" and jobinfo[index].first == true and jobinfo[index]["data"][1] ~= "" then
          api.nvim_command [[silent! cfirst]]
        elseif index == "location" and jobinfo[index].first == true and jobinfo[index]["data"][1] ~= "" then 
          api.nvim_command [[silent! lfirst]]
        end
      end
      jobinfo[index]["data"] = {}
      jobinfo[index]["jobid"] = nil
    end
  end
end

function module.completion(arglead, cmdline, cursorpos)
  local quick = "quickfix: "
  if jobinfo.quickfix.name == "make" then
    quick = quick .. jobinfo.quickfix.makeprg
  elseif jobinfo.quickfix.name == "grep" then
    quick = quick .. jobinfo.quickfix.grepprg
  else
    quick = "quickfix: NULL"
  end

  local locat = "location: "
  if jobinfo.location.name == "make" then
    locat = locat .. jobinfo.location.makeprg
  elseif jobinfo.location.name == "grep" then
    locat = locat .. jobinfo.location.grepprg
  else
    locat = "location: NULL"
  end

  local rtn = quick .. "\n" .. locat .. "\n" .. "all"
  return rtn
end

function module.stop_job(arg)
  local jobstop
  if arg == nil then
    if jobinfo.quickfix.jobid == nil and jobinfo.location.jobid == nil then
      print("No jobs are running, keep moving on...")
    else
      if jobinfo.quickfix.jobid then
        jobinfo.quickfix.stop_job = true
        jobstop = fn.jobstop(jobinfo.quickfix.jobid)
        if not jobstop then
          print("Quickfix jobId is not valid, failed to stop the job.")
        end 
      end
      if jobinfo.location.jobid then
        jobinfo.location.stop_job = true
        jobstop = fn.jobstop(jobinfo.location.jobid)
        if not jobstop then
          print("Location jobId is not valid, failed to stop the job.")
        end
      end
    end
  end

  if arg ~= nil then
    if string.find(arg, "NULL") ~= nil then
      print("No job is running here, keep moving on...")
    else
      arg = string.sub(arg, 1, string.find(arg, ":") - 1)
      jobinfo[arg].stop_job = true
      jobstop = fn.jobstop(jobinfo[arg].jobid)
      if not jobstop then
        print(arg .. " jobIs is not valid, failed to stop the job.")
      end
    end
  end
end

function module.ajob(arg, grep, loc, add, bang)

  local pos
  if loc == 1 then
    pos = "location"
  else
    pos = "quickfix"
  end

  local winnr = fn.win_getid()
  local bufnr = api.nvim_win_get_buf(winnr)
  if grep == 0 then
    get_makeprg(arg, winnr, bufnr, pos)
    get_errorformat(winnr, bufnr, pos)
    jobinfo[pos]["name"] = "make"
  else
    get_grepprg(arg, winnr, bufnr, pos)
    get_grepformat(winnr, bufnr, pos)
    jobinfo[pos]["name"] = "grep"
  end

  if bang == "!" then
    jobinfo[pos].first = false
  else
    jobinfo[pos].first = true
  end

  if add == 1 then
    jobinfo[pos].adding = true
  else
    jobinfo[pos].adding = false
  end

  local opts = {
    on_stderr = handler,
    on_stdout = handler,
    on_exit = handler,
    stderr_buffered = false,
    stdout_buffered = false
  }

  api.nvim_command [[doautocmd QuickFixCmdPre]]

  local job_id
  if grep == 0 then
    job_id = fn.jobstart(jobinfo[pos]["makeprg"], opts)
  else
    job_id = fn.jobstart(jobinfo[pos]["grepprg"], opts)
  end
  jobinfo[pos]["jobid"] = job_id
end

return module

-- lua: et tw=79 ts=2 sts=2 sw=2

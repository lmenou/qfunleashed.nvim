local fn, api = vim.fn, vim.api

module = {}
jobinfo = {}
stop_work = false

-- For plugin development
function module.reload()
  print("Plugin reloaded")
end

local function get_makeprg(arg, winnr, bufnr)
  local function get_buf_makeprg() 
    return api.nvim_buf_get_option(bufnr, 'makeprg') 
  end

  local makeprg
  if pcall(get_buf_makeprg) then
    makeprg = get_buf_makeprg()
  else
    makeprg = vim.api.nvim_get_option('makeprg')
  end

  if arg then
    makeprg = makeprg .. " " .. arg
  end
  makeprg = vim.fn.expandcmd(makeprg)

  jobinfo["makeprg"] = makeprg
end

local function get_errorformat(winnr, bufnr)
  local function get_buf_efm()
    return api.nvim_buf_get_option(bufnr, 'errorformat')
  end

  local efm
  if pcall(get_buf_efm) then
    efm = get_buf_efm()
  else
    efm = api.nvim_get_option('errorformat')
  end

  jobinfo["errorformat"] = efm
end

jobinfo["data"] = {}
local function handler(job_id, data, event)
  if event == "stdout" or event == "stderr" then
    if data then
      vim.list_extend(jobinfo["data"], data)
    end
  end

  if event == "exit" then
    if stop_work then
      print("Job has been stopped.")
      jobinfo["data"] = {}
      stop_work = false
    else
      local opts = {
        title = jobinfo["makeprg"],
        lines = jobinfo["data"],
        efm = jobinfo["errorformat"]
      }
      if localjob == false then
        fn.setqflist({}, " ", opts)
      else
        fn.setloclist(0, {}, " ", opts)
      end
      api.nvim_command [[doautocmd QuickFixCmdPost]]
      if quickopen then
        if localjob == false then
          api.nvim_command [[copen]]
          api.nvim_command [[wincmd k]]
          if first == true and jobinfo["data"][1] ~= "" then
            api.nvim_command [[silent! cfirst]]
          end
        else
          api.nvim_command [[lopen]]
          api.nvim_command [[wincmd k]]
          if first == true and jobinfo["data"][1] ~= "" then
            api.nvim_command [[silent! lfirst]]
          end
        end
      else
        print("Job is done.")
      end
      jobinfo["data"] = {}
    end
  end
end

function module.stop_job()
  local job_id = jobinfo["jobid"]

  if job_id == nil then
    print("No job seems to run.")
  else 
    stop_work = true
    jobstop = fn.jobstop(job_id)
    if jobstop == 0 then
      print("Job Id is not valid, failed to stop the job.")
    end
  end
end

function module.amake(arg, loc, bang)

  local winnr = fn.win_getid()
  local bufnr = api.nvim_win_get_buf(winnr)
  get_makeprg(arg, winnr, bufnr)
  get_errorformat(winnr, bufnr)

  api.nvim_command("doautocmd QuickFixCmdPre")

  if loc == 1 then
    localjob = true
  else
    localjob = false
  end

  if bang == "!" then
    first = false
  else
    first = true
  end

  local opts = {
    on_stderr = handler,
    on_stdout = handler,
    on_exit = handler,
    stderr_buffered = false,
    stdout_buffered = false
  }

  local job_id = fn.jobstart(jobinfo["makeprg"], opts)
  jobinfo["jobid"] = job_id
end

return module

-- lua: et tw=79 ts=2 sts=2 sw=2

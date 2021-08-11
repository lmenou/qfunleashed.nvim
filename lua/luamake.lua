local fn, api = vim.fn, vim.api

module = {}
jobinfo = {}
stop_work = false

-- For plugin development
function module.reload()
  print("Plugin reloaded")
end

-- Plugin 
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

local function get_grepprg(arg, winnr, bufnr)
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

  jobinfo["grepprg"] = grepprg
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

local function get_grepformat(winnr, bufnr)
  local function get_buf_grepfmt()
    return api.nvim_buf_get_option(bufnr, 'grepformat')
  end

  local grepfmt
  if pcall(get_buf_grepfmt) then
    grepfmt = get_buf_grepfmt()
  else
    grepfmt = api.nvim_get_option('grepformat')
  end

  jobinfo["grepformat"] = grepfmt
end

jobinfo["data"] = {}
local function handler(job_id, data, event)
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
    vim.list_extend(jobinfo["data"], data)
  end

  if event == "exit" then
    if stop_work then
      print("Job has been stopped.")
      jobinfo["data"] = {}
      stop_work = false
    else
      local opts
      if jobinfo["name"] == "make" then
        opts = {
          title = jobinfo["makeprg"],
          lines = jobinfo["data"],
          efm = jobinfo["errorformat"]
        }
      else
        opts = {
          title = jobinfo["grepprg"],
          lines = jobinfo["data"],
          efm = jobinfo["grepformat"]
        }
      end
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
        if localjob == false and first == true and jobinfo["data"][1] ~= "" then
          api.nvim_command [[silent! cfirst]]
        elseif localjob == true and first == true and jobinfo["data"][1] ~= "" then 
          api.nvim_command [[silent! lfirst]]
        end
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

function module.ajob(arg, grep, loc, bang)

  local winnr = fn.win_getid()
  local bufnr = api.nvim_win_get_buf(winnr)
  if grep == 0 then
    get_makeprg(arg, winnr, bufnr)
    get_errorformat(winnr, bufnr)
    jobinfo["name"] = "make"
  else
    get_grepprg(arg, winnr, bufnr)
    get_grepformat(winnr, bufnr)
    jobinfo["name"] = "grep"
  end

  api.nvim_command [[doautocmd QuickFixCmdPre]]

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

  local job_id
  if grep == 0 then
    job_id = fn.jobstart(jobinfo["makeprg"], opts)
  else
    job_id = fn.jobstart(jobinfo["grepprg"], opts)
  end
  jobinfo["jobid"] = job_id
end

return module

-- lua: et tw=79 ts=2 sts=2 sw=2

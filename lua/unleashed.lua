local fn, api = vim.fn, vim.api
local Jobs = require "jobs"
local util = require "util"

local M = {}

local jobs = {}
local jobs_list = setmetatable({}, { __index = jobs })

-- [[ JOBS HISTORY AND UTILITIES ]]
function jobs:find_job(job_id)
  for _, v in ipairs(self) do
    if v.jobid == job_id then
      return v
    end
  end

  util.echo_type(
    "ErrorMsg",
    [[E(unleashed): No valid job_id 
    found to handle the job]]
  )
end

function jobs:find_type_job(loc, status)
  local type_job = {}
  for _, v in ipairs(self) do
    if v.loc == loc - 1 and v.status == status then
      table.insert(type_job, v)
    end
  end
  return type_job
end

function jobs:clean_job()
  local count = 0
  for _, v in pairs(self) do
    if v.status == "Done" then
      count = count + 1
    end
  end

  if count > 2 then
    for k, v in pairs(self) do
      if v.status == "Done" then
        table.remove(self, k)
        break
      end
    end
  end
end

-- [[ HANDLER ]]
local function handler(job_id, data, event)
  local job = jobs_list:find_job(job_id)

  if event == "stderr" then
    for k, v in ipairs(data) do
      if v == "" then
        data[k] = nil
      end
    end
    if next(data) then
      util.echo_type("ErrorMsg", data[1])
    end
  end

  if event == "stdout" then
    for k, v in ipairs(data) do
      if v == "" then
        data[k] = nil
      end
    end
    if next(data) then
      for _, v in ipairs(data) do
        job.data[#job.data + 1] = v
      end
    end
  end

  if event == "exit" then
    if job.stop_job then
      util.echo_type("MoreMsg", "Job(s) has(ve) been stopped.")
    else
      if job.loc == 0 then
        job:quickfix_setter()
        if job.first == 1 and job.data ~= nil then
          api.nvim_command [[silent! cfirst]]
        end
        if vim.g.unleashed_build_quick_open == 1 then
          api.nvim_command [[copen | wincmd p]]
        end
      else
        job:location_setter()
        if job.first == 1 and job.data ~= nil then
          api.nvim_command [[silent! lfirst]]
        end
        if vim.g.unleashed_build_quick_open == 1 then
          api.nvim_command [[lopen | wincmd p]]
        end
      end
    end
    api.nvim_command [[doautocmd QuickFixCmdPost]]
    job.status = "Done"
    jobs_list:clean_job()
  end
end

-- [[ THE MODULE ITSELF ]]

function M.stop_job(arg)
  local jobstop

  if tonumber(arg) ~= nil then
    local jobid = tonumber(arg)
    jobstop = fn.jobstop(jobid)
    if jobstop == 0 then
      util.echo_type("ErrorMsg", "Provided jobid is not valid, failed to stop the job")
      return
    else
      local job = jobs_list:find_job(arg)
      job.stop_job = true
    end
  else
    local valid_arg = { "quickfix", "location" }
    local loc, is_valid = util.is_in_table(valid_arg, arg)

    if is_valid then
      local type_job = jobs_list:find_type_job(loc, "Running")
      if not next(type_job) then
        util.echo_type("WarningMsg", "No jobs are running here.")
        return
      end

      for k, v in ipairs(type_job) do
        jobstop = fn.jobstop(v.jobid)
        if not jobstop then
          local err = string.format("Provided jobid %s is not valid, failed to stop this job", tostring(v.jobid))
          util.echo_type("ErrorMsg", err)
        end
        type_job[k].stop_job = true
      end
    else
      util.echo_type("ErrorMsg", "Provided argument is not valid, failed to stop the jobs")
    end
  end
end

function M.ajob(arg, grep, loc, add, bang)
  local t = Jobs:new()

  t.loc = loc

  if bang == "!" then
    t.first = 0
  else
    t.first = 1
  end

  t.adding = add
  t.data = {}

  local opts = {
    on_stderr = handler,
    on_stdout = handler,
    on_exit = handler,
    stderr_buffered = false,
    stdout_buffered = false,
  }

  api.nvim_command [[doautocmd QuickFixCmdPre]]

  if grep == 1 then
    t.type = "grep"
    t.grepformat = vim.o.grepformat
    t:get_grepprg(arg)
    t.status = "Running"
    t.jobid = fn.jobstart(t.grepprg, opts)
  else
    t.type = "make"
    t.errorformat = vim.o.errorformat
    t:get_makeprg(arg)
    t.status = "Running"
    t.jobid = fn.jobstart(t.makeprg, opts)
  end

  jobs_list[#jobs_list + 1] = t
end

return M

-- lua: et tw=79 ts=2 sts=2 sw=2

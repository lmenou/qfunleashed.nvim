local fn, api = vim.fn, vim.api
local Jobs = require "unleashed.jobs"
local util = require "unleashed"

local M = {}

local jobs = {}
local jobs_list = setmetatable({}, { __index = jobs })

-- [[ JOBS HISTORY AND UTILITIES ]]
function jobs:find_job(job_id)
  for k, v in ipairs(self) do
    if v.jobid == job_id then
      return k, v
    end
  end

  util.echo_type("ErrorMsg", "No valid job_id found to handle the job")
end

function jobs:find_job_to_stop(loc, status)
  local yes = loc < 3 and true or false
  if yes then
    for k, v in ipairs(self) do
      if v.loc == loc - 1 and v.status == status then
        self[k].to_stop = true
      end
    end
  else
    for k, v in ipairs(self) do
      if v.status == status then
        self[k].to_stop = true
      end
    end
  end
end

function jobs:clean_job(index)
  table.remove(self, index)
end

function jobs:job_checker(loc)
  for _, v in ipairs(self) do
    if v.loc == loc and v.status == "Running" then
      local prg = v.type == "make" and util.first_word(v.makeprg, " ") or util.first_word(v.grepprg, " ")
      local list = v.loc == 1 and "location list" or "quickfix list"
      local msg = string.format("%s is running on %s", prg, list)
      util.echo_type("ErrorMsg", msg)
      return true
    end
  end
  return false
end

-- [[ HANDLER ]]
local function handler(job_id, data, event)
  local index, job = jobs_list:find_job(job_id)

  if event == "stdout" or event == "stderr" then
    job:write_lines(data)
  end

  if event == "exit" then
    if job.stop_job then
      util.echo_type("MoreMsg", "Job(s) has(ve) been stopped.")
    else
      if job.loc == 0 then
        job:quickfix_setter()
        job:quickfix_out()
      else
        job:location_setter()
        job:location_out()
      end
    end
    api.nvim_command [[doautocmd QuickFixCmdPost]]
    job.status = "Done"
    if vim.g.qfunleashed_quick_window == 1 then
      api.nvim_win_close(job.win_id, true)
    end
    api.nvim_buf_delete(job.scratch_buf_id, { force = true, unload = false })
    jobs_list:clean_job(index)
  end
end

-- [[ THE MODULE ITSELF ]]

function M.stop_job(tab)
  local jobstop
  local valid_arg = { "quickfix", "location", "all", "" }
  local loc, valid = util.is_in_table(valid_arg, tab.arg)

  if valid then
    jobs_list:find_job_to_stop(loc, "Running")

    if not next(jobs_list) then
      util.echo_type("WarningMsg", "Nothing is running here...")
    end

    for k, v in ipairs(jobs_list) do
      if v.to_stop then
        jobstop = fn.jobstop(v.jobid)
        if not jobstop then
          local msg = string.format("Failed to stop the job %s", tostring(v.jobid))
          util.echo_type("ErrorMsg", msg)
        end
        jobs_list[k].stop_job = true
      end
    end
  else
    util.echo_type("ErrorMsg", "Given arg is not valid !")
  end
end

function M.ajob(tab)
  local loc = string.sub(tab.name, 1, 1) == "L" and 1 or 0
  local adding = string.find(tab.name, "Add") and 1 or 0

  local error = jobs_list:job_checker(loc)
  if error then
    return
  end

  local t = Jobs:new()
  t.loc = loc

  if tab.bang then
    t.first = 0
  else
    t.first = 1
  end

  t.adding = adding
  t.data = {}

  local opts = {
    on_stderr = handler,
    on_stdout = handler,
    on_exit = handler,
    stderr_buffered = false,
    stdout_buffered = false,
  }

  api.nvim_command [[doautocmd QuickFixCmdPre]]

  if string.find(tab.name, "[Gg]rep") then
    t.type = "grep"
    t.grepformat = vim.o.grepformat
    t:get_grepprg(tab.args)
    t.jobid = fn.jobstart(t.grepprg, opts)
  elseif string.find(tab.name, "[Mm]ake") then
    t.type = "make"
    t.errorformat = vim.o.errorformat
    t:get_makeprg(tab.args)
    t.jobid = fn.jobstart(t.makeprg, opts)
  else
    t.type = "find"
    t:get_findprg(tab.args)
    t.jobid = fn.jobstart(t.findprg, opts)
  end
  t.status = "Running"

  t:create_buffer()
  if vim.g.qfunleashed_quick_window == 1 then
    t:create_window()
  end
  jobs_list[#jobs_list + 1] = t
end

return M

-- lua: et tw=79 ts=2 sts=2 sw=2

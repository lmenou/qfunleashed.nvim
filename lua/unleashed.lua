local fn, api = vim.fn, vim.api
local Jobs = require"jobs"
local util = require"util"

local M = {}

local jobs = {}

-- [[ FIND THE JOB TO ACT ON ]]
function jobs:find_job(job_id)
  print(vim.inspect(jobs))
end

function jobs:clean_job()
  local count = 0
  for _, v in pairs(self) do
    if v.status == "Done" then
      count = count + 1
    end
  end

  if count >= 5 then
    for _, v in pairs(self) do
      if v.status == "Done" then
        table.remove(self, 1)
        break
      end
    end
  end
end

-- [[ HANDLER ]]
local function handler(job_id, data, event)
  local job = jobs:find_job(job_id)

  if event == "stderr" then
    if not data == {""} then
      for _, v in ipairs(data) do
        util.echo_type("ErrorMsg", v)
      end
    end
    job.status = "Error"
  end

  if event == "stdout" then
    for k, v in ipairs(data) do
      if v == "" then
        data[k] = nil
      end
    end
    if next(data) then
      for _, v in ipairs(data) do
        job.data[#(job.data)+1] = v
      end
    end
  end

  if event == "exit" then
    if job.stop_job then
      print("Job(s) has(ve) been stopped.")
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
        if job.first == true and job.data ~= nil then
          api.nvim_command [[silent! lfirst]]
        end
        if vim.g.unleashed_build_quick_open == 1 then
          api.nvim_command [[lopen | wincmd p]]
        end
      end
    end
    api.nvim_command [[doautocmd QuickFixCmdPost]]
    job.status = "Done"
    jobs:clean_job()
  end
end

function M.stop_job(arg)
  util.echo_type("ErrorMsg", arg)
end

function M.ajob(arg, grep, loc, add, bang)

  -- Define new job
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
    stdout_buffered = false
  }

  api.nvim_command [[doautocmd QuickFixCmdPre]]

  if grep == 1 then
    t.type = "grep"
    t.grepformat = vim.o.grepformat
    t:get_grepprg(arg)
    t.status = "Running"
    jobs[#jobs+1] = t
    t.jobid = fn.jobstart(t.grepprg, opts)
  else
    t.type = "make"
    t.errorformat = vim.o.errorformat
    t:get_makeprg(arg)
    t.status = "Running"
    jobs[#jobs+1] = t
    t.jobid = fn.jobstart(t.makeprg, opts)
  end

end

return M

-- lua: et tw=79 ts=2 sts=2 sw=2

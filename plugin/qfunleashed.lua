-- Prevent to load twice
if vim.g.loaded_qfunleashed then
  return
end
vim.g.loaded_qfunleashed = 1

-- Save user compatible options
local save_cpo = vim.opt.cpo
vim.opt.cpo = "aABceFs_"

-- Wish to see the quickfix list or not ?
-- Set the global value
if not vim.g.qfunleashed_quick_open then
  vim.g.qfunleashed_quick_open = 0
end

-- Wish to see the job window or not ?
-- Set the global value
if not vim.g.qfunleashed_quick_window then
  vim.g.qfunleashed_quick_window = 0
end

-- Set a find program for Unix like OS
if not vim.g.qfunleashed_findprg then
  if vim.fn.has "mac" == 1 then
    vim.g.qfunleashed_findprg = 'find $* -print0 2> /dev/null | xargs -0 stat -f "%N:1:%f"'
  elseif vim.fn.has "linux" == 1 then
    vim.g.qfunleashed_findprg = 'find $* -printf "%p:1:1:%f\n"'
  else
    vim.api.nvim_echo({ { "M(unleashed): Please, set a qfunleashed_findprg for your OS", "ModeMsg" } }, true, {})
  end
end

-- NOTE: Possible but perhaps useless
-- Following same convention, it should possible to add a MakeAdd and an LmakeAdd command

local ajob = require("unleashed.unleashed").ajob
local stop_job = require("unleashed.unleashed").stop_job

local makers = { { "Make", "Lmake" }, { bang = true, bar = true, nargs = "*", complete = "file" } }
local grepfinders = {
  { "Grep", "Lgrep", "GrepAdd", "LgrepAdd", "Find", "Lfind" },
  { bang = true, bar = true, nargs = "+", complete = "file" },
}

local create_commands = function(tab_cmds, tab_opts)
  for _, v in pairs(tab_cmds) do
    vim.api.nvim_create_user_command(v, ajob, tab_opts)
  end
end

for _, v in pairs { makers, grepfinders } do
  create_commands(v[1], v[2])
end

vim.api.nvim_create_user_command("StopJob", stop_job, {
  bar = true,
  nargs = "?",
  complete = "custom,stopcmd#arg",
})

-- Restore compatible options
vim.opt.cpo = save_cpo

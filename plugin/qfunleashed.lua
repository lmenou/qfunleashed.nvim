-- Prevent to load twice
if vim.g.loaded_qfunleashed then
  return
end
vim.g.loaded_qfunleashed = 1

local util = require "unleashed"

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

vim.api.nvim_command [[command! -bang -bar -nargs=* -complete=file Make 
      lua require("unleashed.unleashed").ajob(<q-args>, 0, 0, 0, "<bang>") ]]
vim.api.nvim_command [[ command! -bang -bar -nargs=* -complete=file Lmake
      lua require("unleashed.unleashed").ajob(<q-args>, 0, 1, 0, "<bang>") ]]

-- NOTE: Possible but perhaps useless
-- Following same convention, it should possible to add a MakeAdd and an LmakeAdd command

vim.api.nvim_command [[ command! -bang -bar -nargs=+ -complete=file Grep 
      lua require("unleashed.unleashed").ajob(<q-args>, 1, 0, 0, "<bang>") ]]
vim.api.nvim_command [[ command! -bang -bar -nargs=+ -complete=file Lgrep 
      lua require("unleashed.unleashed").ajob(<q-args>, 1, 1, 0, "<bang>") ]]
vim.api.nvim_command [[ command! -bang -bar -nargs=+ -complete=file GrepAdd
      lua require("unleashed.unleashed").ajob(<q-args>, 1, 0, 1, "<bang>") ]]
vim.api.nvim_command [[ command! -bang -bar -nargs=+ -complete=file LgrepAdd
      lua require("unleashed.unleashed").ajob(<q-args>, 1, 1, 1, "<bang>") ]]
vim.api.nvim_command [[ command! -bang -bar -nargs=+ -complete=file Find 
      lua require("unleashed.unleashed").ajob(<q-args>, 2, 0, 0, "<bang>") ]]
vim.api.nvim_command [[ command! -bang -bar -nargs=+ -complete=file Lfind 
      lua require("unleashed.unleashed").ajob(<q-args>, 2, 1, 0, "<bang>") ]]
vim.api.nvim_command [[ command -bar -nargs=? -complete=custom,stopcmd#arg StopJob
      lua require("unleashed.unleashed").stop_job(<f-args>) ]]

-- Restore compatible options
vim.opt.cpo = save_cpo

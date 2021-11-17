" Prevent to load twice
if exists('g:loaded_unleashed')
  finish
endif
let g:loaded_unleashed = 1

" Save user compatible options
let s:save_cpo = &cpo
set cpo&vim


function! s:LuamakeComplete(arglead, cmdline, cursorpos)
  let l:list = luaeval("require'build'.completion()")
  return l:list
endfunction

" Wish to see the quickfix list or not ?
" Set the global value
if !exists('g:unleashed_build_quick_open')
  let g:unleashed_build_quick_open = 0
end

command! -bang -bar -nargs=* -complete=file Make 
      \ lua require("build").ajob(<q-args>, 0, 0, 0, "<bang>")
command! -bang -bar -nargs=* -complete=file Lmake 
      \ lua require("build").ajob(<q-args>, 0, 1, 0, "<bang>")
command! -bang -bar -nargs=* -complete=file MakeAdd
      \ lua require("build").ajob(<q-args>, 0, 0, 1, "<bang>")
command! -bang -bar -nargs=* -complete=file LmakeAdd
      \ lua require("build").ajob(<q-args>, 0, 1, 1, "<bang>")
command! -bang -bar -nargs=+ -complete=file Grep 
      \ lua require("build").ajob(<q-args>, 1, 0, 0, "<bang>")
command! -bang -bar -nargs=+ -complete=file Lgrep 
      \ lua require("build").ajob(<q-args>, 1, 1, 0, "<bang>")
command! -bang -bar -nargs=+ -complete=file GrepAdd
      \ lua require("build").ajob(<q-args>, 1, 0, 1, "<bang>")
command! -bang -bar -nargs=+ -complete=file LgrepAdd
      \ lua require("build").ajob(<q-args>, 1, 1, 1, "<bang>")
command -bar -nargs=? -complete=custom,<sid>LuamakeComplete StopJob
      \ lua require("build").stop_job(<f-args>)

" Restore compatible options
let &cpo = s:save_cpo
unlet s:save_cpo
" vim: et ts=2 sts=2 sw=2 tw=79

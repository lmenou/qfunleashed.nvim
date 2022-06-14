" Prevent to load twice
if exists('g:loaded_qfunleashed')
  finish
endif
let g:loaded_qfunleashed = 1

" Save user compatible options
let s:save_cpo = &cpo
set cpo&vim

" Wish to see the quickfix list or not ?
" Set the global value
if !exists('g:qfunleashed_quick_open')
  let g:qfunleashed_quick_open = 0
end

" Wish to see the job window or not ?
" Set the global value
if !exists('g:qfunleashed_quick_window')
  let g:qfunleashed_quick_window = 0
end

if !exists('g:qfunleashed_findprg')
  " MacOs Unix flavor
  " TODO: Provide better defaults
  let g:qfunleashed_findprg = 'find $* -print0 2> /dev/null | xargs -0 stat -f "%N:1:%f"'
end

command! -bang -bar -nargs=* -complete=file Make 
      \ lua require("unleashed.unleashed").ajob(<q-args>, 0, 0, 0, "<bang>")
command! -bang -bar -nargs=* -complete=file Lmake
      \ lua require("unleashed.unleashed").ajob(<q-args>, 0, 1, 0, "<bang>")

" NOTE: Possible but perhaps useless
" command! -bang -bar -nargs=* -complete=file MakeAdd
"       \ lua require("unleashed.unleashed").ajob(<q-args>, 0, 0, 1, "<bang>")
" command! -bang -bar -nargs=* -complete=file LmakeAdd
"       \ lua require("unleashed.unleashed").ajob(<q-args>, 0, 1, 1, "<bang>")

command! -bang -bar -nargs=+ -complete=file Grep 
      \ lua require("unleashed.unleashed").ajob(<q-args>, 1, 0, 0, "<bang>")
command! -bang -bar -nargs=+ -complete=file Lgrep 
      \ lua require("unleashed.unleashed").ajob(<q-args>, 1, 1, 0, "<bang>")
command! -bang -bar -nargs=+ -complete=file GrepAdd
      \ lua require("unleashed.unleashed").ajob(<q-args>, 1, 0, 1, "<bang>")
command! -bang -bar -nargs=+ -complete=file LgrepAdd
      \ lua require("unleashed.unleashed").ajob(<q-args>, 1, 1, 1, "<bang>")
command! -bang -bar -nargs=+ -complete=file Find 
      \ lua require("unleashed.unleashed").ajob(<q-args>, 2, 0, 0, "<bang>")
command! -bang -bar -nargs=+ -complete=file Lfind 
      \ lua require("unleashed.unleashed").ajob(<q-args>, 2, 1, 0, "<bang>")
command -bar -nargs=? -complete=custom,stopcmd#arg StopJob
      \ lua require("unleashed.unleashed").stop_job(<f-args>)

" Restore compatible options
let &cpo = s:save_cpo
unlet s:save_cpo
" vim: et ts=2 sts=2 sw=2 tw=79

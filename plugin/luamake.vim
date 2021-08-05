" Prevent to load twice
" TODO: To change !
if exists('g:loaded_luamake')
  finish
endif
let g:loaded_luamake = 1

" Wish to see the quickfix list or not ?
" Set the global value
if !exists('g:quick_open') || g:quick_open == 0
  lua quickopen = false
else
  lua quickopen = true
endif

command! -bang -bar -nargs=* -complete=file Amake 
      \ lua require("luamake").amake(<q-args>, 0)
command! -bang -bar -nargs=* -complete=file Lamake 
      \ lua require("luamake").amake(<q-args>, 1)
command! -bang -bar StopJob
      \ lua require("luamake").stop_job()

" Prevent to load twice
" if exists('g:loaded_luamake')
"   finish
" endif
" let g:loaded_luamake = 1

" Save user compatible options
let s:save_cpo = &cpo
set cpo&vim

" For the developement of the plugin
function! Reload()
lua << EOF
  for k in pairs(package.loaded) do 
    if k:match("^luamake") then 
      package.loaded[k] = nil 
    end
  end
  require("luamake").reload()
  require("luamake")
EOF
endfunction
command Reload call Reload()
nnoremap <Leader>pa :Reload<CR>

" Wish to see the quickfix list or not ?
" Set the global value
if !exists('g:quick_open') || g:quick_open == 0
  lua quickopen = false
else
  lua quickopen = true
endif

command! -bang -bar -nargs=* -complete=file Amake 
      \ lua require("luamake").ajob(<q-args>, 0, 0, 0, "<bang>")
command! -bang -bar -nargs=* -complete=file Lamake 
      \ lua require("luamake").ajob(<q-args>, 0, 1, 0, "<bang>")
command! -bang -bar -nargs=* -complete=file AmakeAdd
      \ lua require("luamake").ajob(<q-args>, 0, 0, 1, "<bang>")
command! -bang -bar -nargs=* -complete=file LamakeAdd
      \ lua require("luamake").ajob(<q-args>, 0, 1, 1, "<bang>")
command! -bang -bar -nargs=+ -complete=file Agrep 
      \ lua require("luamake").ajob(<q-args>, 1, 0, 0, "<bang>")
command! -bang -bar -nargs=+ -complete=file Lagrep 
      \ lua require("luamake").ajob(<q-args>, 1, 1, 0, "<bang>")
command! -bang -bar -nargs=+ -complete=file AgrepAdd
      \ lua require("luamake").ajob(<q-args>, 1, 0, 1, "<bang>")
command! -bang -bar -nargs=+ -complete=file LagrepAdd
      \ lua require("luamake").ajob(<q-args>, 1, 1, 1, "<bang>")
command! -bang -bar StopJob
      \ lua require("luamake").stop_job()

" Restore compatible options
let &cpo = s:save_cpo
unlet s:save_cpo
" vim: et ts=2 sts=2 sw=2 tw=79

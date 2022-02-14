if exists('g:autoloaded_unleashed')
  finish
endif
let g:autoloaded_unleashed = 1

" Function for completion on command line
function stopcmd#arg(arglead, cmdline, cursorpos)
  let l:list = "location\nquickfix\nall"
  return l:list
endfunction

" vim: et ts=2 sts=2 sw=2 tw=79

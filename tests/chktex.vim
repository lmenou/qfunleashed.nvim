" Vim compiler file
" Compiler: chktex for Latex
" Set Compiler and respective ErrorFormat

if exists("current_compiler")
  finish
endif
let current_compiler = "chktex"

if exists(":CompilerSet") != 2		" older Vim always used :setlocal
  command -nargs=* CompilerSet setlocal <args>
endif

CompilerSet makeprg=chktex
CompilerSet errorformat=%EError\ %n\ in\ %f\ line\ %l:\ %m,%WWarning\ %n\ in\ %f\ line\ %l:\ %m,%WMessage\ %n\ in\ %f\ line\ %l:\ %m,%Z%p^,%-G%.%#

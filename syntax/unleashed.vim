if exists("b:current_syntax")
  finish
endif

syntax match unHeader /^UnleashedStatus:$/
syntax match quickHeader /^Quickfix\slist:$/
syntax match locHeader /^Location\slist:$/

hi def link unHeader Function
hi def link quickHeader Label
hi def link locHeader Label

let b:current_syntax = "unleashed"

" vim: et ts=2 sts=2 sw=2 tw=79

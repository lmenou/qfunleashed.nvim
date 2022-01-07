syntax match unHeader /^UnleashedStatus:$/
syntax match quickHeader /^Quickfix\slist:$/
syntax match locHeader /^Location\slist:$/

hi def link unHeader Function
hi def link quickHeader Label
hi def link locHeader Label

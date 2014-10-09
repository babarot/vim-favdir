if exists("g:loaded_favdir")
  finish
endif
let g:loaded_favdir = 1

let s:save_cpo = &cpo
set cpo&vim

command! -nargs=?                                      Reg  call favdir#reg(<q-args>)
command! -nargs=? -complete=customlist,favdir#complete Show call favdir#show(<q-args>)
command! -nargs=1 -complete=customlist,favdir#complete Gg   call favdir#go(<q-args>)
command! -nargs=+ -complete=customlist,favdir#complete Del  call favdir#del(<f-args>)

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ft=vim ts=2 sw=2 sts=2:

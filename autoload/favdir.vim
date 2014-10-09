let s:save_cpo = &cpo
set cpo&vim

let s:favdir_logfilepath = $HOME . '/.favdir/favdirlog'
if !exists('g:favdir_filepath')
  let g:favdir_filepath = $HOME . '/.favdir/favdirlist'
endif

function! favdir#show(name) "{{{1
  if !filereadable(g:favdir_filepath)
    redraw
    echohl ErrorMsg | echo g:favdir_filepath.' does not exist' | echohl NONE
    return 0
  endif

  if getfsize(g:favdir_filepath) == 0
    redraw
    echohl ErrorMsg | echo g:favdir_filepath . ' is empty' | echohl NONE
    return 0
  endif

  for line in readfile(g:favdir_filepath)
    let name = substitute(line, '\s.*', '', '')
    let path = substitute(line, '.*\s', '', '')

    if len(filter(readfile(s:favdir_logfilepath), 'substitute(v:val, ".\\+\\t\\(.\\+\\)\\t.\\+", "\\1", "g") == name')) >= 1
      echohl WarningMsg | echo printf("%-15s", name) | echohl NONE
    else
      echohl Directory | echo printf("%-15s", name) | echohl NONE
    endif
    echon printf("%s", path)
  endfor
endfunction

function! favdir#reg(name) "{{{1
  let name = empty(a:name) ? fnamemodify(getcwd(), ":t") : a:name
  silent! let file_list = readfile(g:favdir_filepath)

  if empty(filter(file_list, 'substitute(v:val, "\\s.*", "", "g") == a:name'))
    execute ":redir! >>" . g:favdir_filepath
    silent echon printf("%-15s%s\n", name, getcwd())
    redir END
    echo 'Favdir: ' . name . ' added'
  else
    redraw
    echohl ErrorMsg | echo 'Favdir: ' . a:name . ': already exists' | echohl NONE
  endif
endfunction

function! favdir#go(word) "{{{1
  let file_list = readfile(g:favdir_filepath)
  call filter(file_list, 'substitute(v:val, "\\s.*", "", "g") == a:word')

  let name = substitute(join(file_list, "\n"), '\s.*', '', 'g')
  let path = substitute(join(file_list, "\n"), '.*\s', '', 'g')
  if empty(name)
    redraw
    echohl ErrorMsg | echo 'Favdir: no match' | echohl NONE
    return 0
  endif

  if empty(path) || !isdirectory(path)
    redraw
    echohl ErrorMsg | echo path . ': No such directory' | echohl NONE
    return 0
  endif

  execute 'cd' path
  echo 'Favdir: cd ' . substitute(path, $HOME, '~', 'g') . ' successfully'
  execute ":redir! >>" . s:favdir_logfilepath
  silent echo printf("%s\t%s\t%s", strftime("%Y/%m/%d %H:%M:%S"), name, path)
  redir END
endfunction

function! favdir#del(...) "{{{1
  let file_list = readfile(g:favdir_filepath)
  let deleted = []
  for item in a:000
    if len(filter(copy(file_list), 'substitute(v:val, "\\s.*", "", "g") == item')) >= 1
      call add(deleted, item)
    endif
    call filter(file_list, 'substitute(v:val, "\\s.*", "", "g") != item')
  endfor

  if len(deleted) >= 1
    echo 'Deleted ' . join(deleted, " ")
  else
    echohl ErrorMsg | echo 'Favdir: no match' | echohl None
    return 0
  endif
  call writefile(file_list, g:favdir_filepath)
endfunction

function! favdir#complete(arglead,cmdline,cursorpos) "{{{1
  if !filereadable(g:favdir_filepath)
    return
  endif
  let lists = []
  for word in readfile(g:favdir_filepath)
    call add(lists, substitute(word, '\s.*', '', 'g'))
  endfor

  if a:arglead == ''
    return lists
  else
    return filter(copy(lists), 'v:val =~? a:arglead')
  endif
endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et fdm=marker ft=vim ts=2 sw=2 sts=2:

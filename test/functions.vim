let s:suite = themis#suite('parser')
let s:assert = themis#helper('assert')

function! s:suite.sort()
  let candidates = []
  for i in range(1, 100)
    call add(candidates, { 'vimfiler__filename' : 'foo'.i.'.txt'.i })
  endfor

  " Benchmark.
  let start = reltime()
  call vimfiler#helper#_sort_human(copy(candidates), 0)
  echomsg reltimestr(reltime(start))
  let g:start = reltime()
  call vimfiler#helper#_sort_human(copy(candidates), 1)
  echomsg reltimestr(reltime(start))

  call s:assert.equals(vimfiler#helper#_sort_human(copy(candidates), 0),
        \ vimfiler#helper#_sort_human(copy(candidates), 1))
endfunction

" vim:foldmethod=marker:fen:

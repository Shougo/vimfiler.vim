scriptencoding utf-8

" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}

Context functions
  It tests sort functions.
    let candidates = []
    for i in range(1, 100)
      call add(candidates, { 'vimfiler__filename' : 'foo'.i.'.txt'.i })
    endfor

    " Benchmark.
    let start = reltime()
    call vimfiler#helper#_sort_human(copy(candidates), 0)
    echomsg reltimestr(reltime(start))
    let start = reltime()
    call vimfiler#helper#_sort_human(copy(candidates), 1)
    echomsg reltimestr(reltime(start))

    ShouldEqual vimfiler#helper#_sort_human(copy(candidates), 0),
          \ vimfiler#helper#_sort_human(copy(candidates), 1)
  End
End

Fin

" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}

" vim:foldmethod=marker:fen:

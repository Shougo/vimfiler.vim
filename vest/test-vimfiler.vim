scriptencoding utf-8

" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}

Context functions
  It tests sort functions.
    let g:candidates = []
    for g:i in range(1, 100)
      call add(g:candidates, { 'vimfiler__filename' : 'foo'.i.'.txt'.i })
    endfor

    " Benchmark.
    let g:start = reltime()
    call vimfiler#helper#_sort_human(copy(g:candidates), 0)
    echomsg reltimestr(reltime(g:start))
    let g:start = reltime()
    call vimfiler#helper#_sort_human(copy(g:candidates), 1)
    echomsg reltimestr(reltime(g:start))

    ShouldEqual vimfiler#helper#_sort_human(copy(g:candidates), 0),
          \ vimfiler#helper#_sort_human(copy(g:candidates), 1)
  End
End

Fin

" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}

" vim:foldmethod=marker:fen:

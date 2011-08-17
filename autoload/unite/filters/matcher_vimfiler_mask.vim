"=============================================================================
" FILE: matcher_vimfiler_mask.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 17 Aug 2011.
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================

let s:save_cpo = &cpo
set cpo&vim

function! unite#filters#matcher_vimfiler_mask#define()"{{{
  return s:matcher
endfunction"}}}

let s:matcher = {
      \ 'name' : 'matcher_vimfiler/mask',
      \ 'description' : 'vimfiler mask matcher',
      \}

function! s:matcher.filter(candidates, context)"{{{
  if a:context.input == ''
    return a:candidates
  endif

  let l:candidates = []
  let l:masks = map(split(a:context.input, '\\\@<! '),
          \ 'substitute(v:val, "\\\\ ", " ", "g")')
  for l:candidate in a:candidates
    let l:matched = 0
    for l:mask in l:masks
      if l:mask =~ '^!'
        if l:mask == '!'
          continue
        endif

        " Exclusion.
        let l:mask = unite#escape_match(l:mask)
        if l:candidate.word !~ l:mask
          let l:matched = 1
          break
        endif
      elseif l:mask =~ '\\\@<!\*'
        " Wildcard.
        let l:mask = unite#escape_match(l:mask)
        if l:candidate.word =~ l:mask
          let l:matched = 1
          break
        endif
      else
        let l:mask = substitute(l:mask, '\\\(.\)', '\1', 'g')
        if stridx((&ignorecase ?
              \ tolower(l:candidate.word) : l:candidate.word), l:mask) != -1
          let l:matched = 1
          break
        endif
      endif
    endfor

    if l:matched
      call add(l:candidates, l:candidate)
    endif
  endfor

  return l:candidates
endfunction"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker

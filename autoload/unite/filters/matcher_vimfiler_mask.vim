"=============================================================================
" FILE: matcher_vimfiler_mask.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
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

function! unite#filters#matcher_vimfiler_mask#define() "{{{
  return s:matcher
endfunction"}}}

let s:matcher = {
      \ 'name' : 'matcher_vimfiler/mask',
      \ 'description' : 'vimfiler mask matcher',
      \}

function! s:matcher.filter(candidates, context) "{{{
  if a:context.input == ''
    return a:candidates
  endif

  let candidates = filter(copy(a:candidates),
        \ "v:val.vimfiler__is_directory")
  let input = a:context.input
  if &ignorecase
    let input = tolower(input)
  endif
  let masks = map(split(input, '\\\@<! '),
          \ 'substitute(v:val, "\\\\ ", " ", "g")')
  for candidate in filter(copy(a:candidates),
        \ "!v:val.vimfiler__is_directory")
    let matched = 0
    for mask in masks
      if mask =~ '^!'
        if mask == '!'
          continue
        endif

        " Exclusion.
        let mask = unite#util#escape_match(mask)
        if candidate.vimfiler__abbr !~ mask
          let matched = 1
          break
        endif
      elseif mask =~ '\\\@<!\*'
        " Wildcard.
        let mask = unite#util#escape_match(mask)
        if candidate.vimfiler__abbr =~ mask
          let matched = 1
          break
        endif
      else
        let mask = substitute(mask, '\\\(.\)', '\1', 'g')
        if stridx((&ignorecase ?
              \ tolower(candidate.vimfiler__abbr) :
              \ candidate.vimfiler__abbr), mask) != -1
          let matched = 1
          break
        endif
      endif
    endfor

    if matched
      call add(candidates, candidate)
    endif
  endfor

  return candidates
endfunction"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker

"=============================================================================
" FILE: vimfiler/mapping.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 17 Oct 2011.
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

function! unite#sources#vimfiler_mapping#define()"{{{
  return s:source
endfunction"}}}

let s:source = {
      \ 'name' : 'vimfiler/mapping',
      \ 'description' : 'candidates from vimfiler mappings',
      \ 'hooks' : {},
      \ 'is_listed' : 0,
      \ }

let s:cached_result = []
function! s:source.hooks.on_init(args, context)"{{{
  if &filetype != 'vimfiler'
    let s:cached_result = []
    return
  endif

  " Get mapping list.
  redir => redir
  silent! nmap <buffer>
  redir END

  let s:cached_result = []
  for line in map(split(redir, '\n'),
        \ "substitute(v:val, '<NL>', '<C-J>', 'g')")
    let map = matchstr(line, '^\a*\s*\zs\S\+')
    if map !~ '^<' || map =~ '^<SNR>'
      continue
    endif
    let map = substitute(map, '\(<.*>\)', '\\\1', 'g')

    call add(s:cached_result, {
          \ 'word' : substitute(line, '<NL>', '<C-j>', 'g'),
          \ 'kind' : 'command',
          \ 'action__command' : 'execute "normal ' . map . '"',
          \ })
  endfor
endfunction"}}}

function! s:source.gather_candidates(args, context)"{{{
  return s:cached_result
endfunction"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker

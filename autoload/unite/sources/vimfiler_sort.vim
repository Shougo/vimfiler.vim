"=============================================================================
" FILE: vimfiler/sort.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 16 Aug 2011.
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

function! unite#sources#vimfiler_sort#define()"{{{
  return s:source
endfunction"}}}

let s:source = {
      \ 'name' : 'vimfiler/sort',
      \ 'description' : 'candidates from vimfiler sort method',
      \ 'default_action' : 'sort',
      \ 'action_table' : {},
      \ 'hooks' : {}
      \ }

function! s:source.hooks.on_init(args, context)"{{{
  if &filetype !=# 'vimfiler'
    return
  endif

  let a:context.source__sort = b:vimfiler.sort_type
endfunction"}}}

function! s:source.gather_candidates(args, context)"{{{
  if !has_key(a:context, 'source__sort')
    return
  endif

  call unite#print_message('[vimfiler/sort] Current sort type: ' . a:context.source__sort)
  call unite#print_message('[vimfiler/sort] (Upper case is descending order)')

  return map([ 'none', 'size', 'extension', 'filename', 'time', 'manual',
        \ 'None', 'Size', 'Extension', 'Filename', 'Time', 'Manual', ], '{
        \ "word" : v:val,
        \ "action__sort" : v:val,
        \ }')
endfunction"}}}

" Actions"{{{
let s:action_table = {}

let s:action_table.sort = {
      \ 'description' : 'sort vimfiler items',
      \ }
function! s:action_table.sort.func(candidate)"{{{
  if &filetype !=# 'vimfiler'
    return
  endif

  let b:vimfiler.sort_type = a:candidate.action__sort
  call vimfiler#force_redraw_screen()
endfunction"}}}

let s:source.action_table['*'] = s:action_table
unlet! s:action_table
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker

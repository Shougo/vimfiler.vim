"=============================================================================
" FILE: vimfiler/mask.vim
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

function! unite#sources#vimfiler_mask#define() "{{{
  return s:source
endfunction"}}}

let s:source = {
      \ 'name' : 'vimfiler/mask',
      \ 'description' : 'change vimfiler mask',
      \ 'default_action' : 'change',
      \ 'action_table' : {},
      \ 'hooks' : {},
      \ 'is_listed' : 0,
      \ 'filters' : [ 'matcher_vimfiler/mask' ],
      \ }

function! s:source.hooks.on_init(args, context) "{{{
  if &filetype !=# 'vimfiler'
    return
  endif

  let a:context.source__mask = b:vimfiler.current_mask
  let a:context.source__candidates = b:vimfiler.current_files

  call unite#print_message(
        \ '[vimfiler/mask] Current mask: ' . a:context.source__mask)
endfunction"}}}

function! s:source.change_candidates(args, context) "{{{
  if !has_key(a:context, 'source__mask')
    return []
  endif

  return map(add(copy(a:context.source__candidates), {
        \ 'vimfiler__abbr' : 'New mask: "' . a:context.input . '"',
        \ 'vimfiler__is_directory' : 0,
        \ 'vimfiler__nest_level' : 0}), "{
        \ 'word' : v:val.vimfiler__abbr .
        \        (v:val.vimfiler__is_directory ? '/' : ''),
        \ 'abbr' : repeat(' ', v:val.vimfiler__nest_level
         \       * g:vimfiler_tree_indentation) . v:val.vimfiler__abbr .
        \        (v:val.vimfiler__is_directory ? '/' : ''),
        \ 'vimfiler__is_directory' : v:val.vimfiler__is_directory,
        \ 'vimfiler__abbr' : v:val.vimfiler__abbr,
        \ }")
endfunction"}}}

" Actions "{{{
let s:action_table = {}

let s:action_table.change = {
      \ 'description' : 'change current mask',
      \ }
function! s:action_table.change.func(candidate) "{{{
  let b:vimfiler.current_mask = unite#get_context().input
  call vimfiler#redraw_screen()
endfunction"}}}

let s:source.action_table['*'] = s:action_table
unlet! s:action_table
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker

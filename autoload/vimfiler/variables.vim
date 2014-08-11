"=============================================================================
" FILE: variables.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
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

" Global options definition. "{{{
let g:vimfiler_default_columns =
      \ get(g:, 'vimfiler_default_columns', 'type:size:time')
let g:vimfiler_split_rule =
      \ get(g:, 'vimfiler_split_rule', 'topleft')
let g:vimfiler_enable_auto_cd =
      \ get(g:, 'vimfiler_enable_auto_cd', 0)
"}}}

function! vimfiler#variables#get_clipboard() "{{{
  if !exists('s:clipboard')
    let s:clipboard = {'operation' : '', 'files' : []}
  endif

  return s:clipboard
endfunction"}}}

function! vimfiler#variables#get_data_directory() "{{{
  let g:vimfiler_data_directory =
        \ substitute(fnamemodify(get(
        \   g:, 'vimfiler_data_directory',
        \  ($XDG_CACHE_DIR != '' ?
        \   $XDG_CACHE_DIR . '/vimfiler' : expand('~/.cache/vimfiler'))),
        \  ':p'), '\\', '/', 'g')
  if !isdirectory(g:vimfiler_data_directory) && !vimfiler#util#is_sudo()
    call mkdir(g:vimfiler_data_directory, 'p')
  endif

  return g:vimfiler_data_directory
endfunction"}}}

function! vimfiler#variables#default_context() "{{{
  if !exists('s:default_context')
    call s:initialize_default_options()
  endif

  return deepcopy(s:default_context)
endfunction"}}}

function! vimfiler#variables#options() "{{{
  if !exists('s:options')
    let s:options = map(filter(items(vimfiler#variables#default_context()),
          \ "v:val[0] !~ '^vimfiler__'"),
          \ "'-' . substitute(v:val[0], '_', '-', 'g') .
          \ (type(v:val[1]) == type(0) && (v:val[1] == 0 || v:val[1] == 1) ?
          \   '' : '=')")

    " Generic no options.
    let s:options += map(filter(copy(s:options),
          \ "v:val[-1:] != '='"), "'-no' . v:val")
  endif

  return deepcopy(s:options)
endfunction"}}}

function! s:initialize_default_options() "{{{
  let s:default_context = {
        \ 'buffer_name' : 'default',
        \ 'quit' : 1,
        \ 'force_quit' : 0,
        \ 'toggle' : 0,
        \ 'create' : 0,
        \ 'simple' : 0,
        \ 'double' : 0,
        \ 'split' : 0,
        \ 'status' : 0,
        \ 'horizontal' : 0,
        \ 'winheight' : -1,
        \ 'winwidth' : -1,
        \ 'winminwidth' : -1,
        \ 'direction' : g:vimfiler_split_rule,
        \ 'auto_cd' : g:vimfiler_enable_auto_cd,
        \ 'explorer' : 0,
        \ 'reverse' : 0,
        \ 'project' : 0,
        \ 'find' : 0,
        \ 'tab' : 0,
        \ 'alternate_buffer' : bufnr('%'),
        \ 'focus' : 1,
        \ 'invisible' : 0,
        \ 'columns' : g:vimfiler_default_columns,
        \ 'vimfiler__prev_bufnr' : bufnr('%'),
        \ 'vimfiler__winfixwidth' : &l:winfixwidth,
        \ 'vimfiler__winfixheight' : &l:winfixheight,
        \ }
endfunction"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker


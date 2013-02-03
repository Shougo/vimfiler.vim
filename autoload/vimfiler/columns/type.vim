"=============================================================================
" FILE: type.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 03 Feb 2013.
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

function! vimfiler#columns#type#define()
  return s:column
endfunction"}}}

let s:column = {
      \ 'name' : 'type',
      \ 'description' : 'get filetype',
      \ }

function! s:column.length(files, context) "{{{
  return 3
endfunction"}}}

function! s:column.define_syntax(files, context) "{{{
endfunction"}}}

function! s:column.get(file, context) "{{{
  let ext = tolower(a:file.vimfiler__extension)

  if (vimfiler#util#is_windows() && ext ==? 'LNK')
        \ || get(a:file, 'vimfiler__ftype', '') ==# 'link'
    " Symbolic link.
    return '[L]'
  elseif a:file.vimfiler__is_directory
    " Directory.
    return '[D]'
  elseif has_key(g:vimfiler_extensions.text, ext)
    " Text.
    return '[T]'
  elseif has_key(g:vimfiler_extensions.image, ext)
    " Image.
    return '[I]'
  elseif has_key(g:vimfiler_extensions.archive, ext)
    " Archive.
    return '[A]'
  elseif has_key(g:vimfiler_extensions.multimedia, ext)
    " Multimedia.
    return '[M]'
  elseif a:file.vimfiler__filename =~ '^\.'
        \ || has_key(g:vimfiler_extensions.system, ext)
    " System.
    return '[S]'
  elseif a:file.vimfiler__is_executable
    " Execute.
    return '[X]'
  else
    " Others filetype.
    return '   '
  endif
endfunction"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker

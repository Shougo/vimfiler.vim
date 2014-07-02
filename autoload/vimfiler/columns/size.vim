"=============================================================================
" FILE: size.vim
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

if has('python3')
  let s:python = 'python3'
  let s:pyfile = 'py3file'
elseif has('python')
  let s:python = 'python'
  let s:pyfile = 'pyfile'
else
  let s:python = ''
  let s:pyfile = ''
endif

if s:pyfile != ''
  execute s:pyfile escape(expand('<sfile>:p:h'), '\').'/../vimfiler.py'
endif

execute s:python 'vimfiler = VimFiler()'

function! vimfiler#columns#size#define()
  return s:column
endfunction"}}}

let s:column = {
      \ 'name' : 'size',
      \ 'description' : 'get filesize by human',
      \ 'syntax' : 'vimfilerColumn__Size',
      \ }

function! s:column.length(files, context) "{{{
  return 6
endfunction"}}}

function! s:column.define_syntax(context) "{{{
  syntax match   vimfilerColumn__SizeLine
        \ '.*' contained containedin=vimfilerColumn__Size
  highlight def link vimfilerColumn__SizeLine Constant
endfunction"}}}

function! s:column.get(file, context) "{{{
  if a:file.vimfiler__is_directory
    return '      '
  endif

  " Get human file size.
  let filesize = a:file.vimfiler__filesize
  let size = 0
  if filesize < 0
    if a:file.action__path !~ '^\a\w\+:'
          \ && s:python != ''
          \ && getftype(a:file.action__path) !=# 'link'
      let pattern = s:get_python_file_size(a:file.action__path)
    elseif filesize == -2
      " Above 2GB?
      let pattern = '>2.00'
    else
      let pattern = ''
    endif
    let suffix = (pattern != '') ? 'G' : ''
  elseif filesize < 1000
    " B.
    let suffix = 'B'
    let float = ''
    let pattern = printf('%5d', filesize)
  else
    if filesize >= 1000000000
      " GB.
      let suffix = 'G'
      let size = filesize / 1024 / 1024
    elseif filesize >= 1000000
      " MB.
      let suffix = 'M'
      let size = filesize / 1024
    elseif filesize >= 1000
      " KB.
      let suffix = 'K'
      let size = filesize
    endif

    let float = (size%1024)*100/1024
    let digit = size / 1024
    let pattern = (digit < 100) ?
          \ printf('%2d.%02d', digit, float) :
          \ printf('%2d.%01d', digit, float/10)
  endif

  return pattern . suffix
endfunction"}}}

" @vimlint(EVL101, 1, l:pattern)
function! s:get_python_file_size(filename) "{{{
  " Use python interface.
  execute s:python 'vim.command("let pattern = " + str('.
        \ 'vimfiler.getsize(vim.eval('.
        \ '"unite#util#iconv(a:filename, &encoding, \"char\")"))))'
  return string(pattern)
endfunction"}}}
" @vimlint(EVL101, 0, l:pattern)

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker

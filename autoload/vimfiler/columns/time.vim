"=============================================================================
" FILE: time.vim
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

function! vimfiler#columns#time#define()
  return s:column
endfunction"}}}

let s:column = {
      \ 'name' : 'time',
      \ 'description' : 'get filetime',
      \ 'syntax' : 'vimfilerColumn__Time',
      \ }

function! s:column.length(files, context) "{{{
  return len(strftime(g:vimfiler_time_format, 0)) + 1
endfunction"}}}

function! s:column.define_syntax(context) "{{{
  syntax match   vimfilerColumn__TimeNormal
        \ '#[^#]\+' contained
        \ containedin=vimfilerColumn__Time
        \ contains=vimfilerColumn__TimeIgnore
  syntax match   vimfilerColumn__TimeToday
        \ '\~[^~]\+' contained
        \ containedin=vimfilerColumn__Time
        \ contains=vimfilerColumn__TimeIgnore
  syntax match   vimfilerColumn__TimeWeek
        \ '![^!]\+' contained
        \ containedin=vimfilerColumn__Time
        \ contains=vimfilerColumn__TimeIgnore

  if has('conceal')
    " Supported conceal features.
    syntax match   vimfilerColumn__TimeIgnore
          \ '[#~!]' contained conceal
  endif

  highlight def link vimfilerColumn__TimeNormal Identifier
  highlight def link vimfilerColumn__TimeToday Statement
  highlight def link vimfilerColumn__TimeWeek Special
  highlight def link vimfilerColumn__TimeIgnore Ignore
endfunction"}}}

function! s:column.get(file, context) "{{{
  let datemark = s:get_datemark(a:file)
  return (a:file.vimfiler__filetime =~ '^-\?\d\+$' ?
        \  (a:file.vimfiler__filetime == -1 ? '' :
        \    datemark . strftime(g:vimfiler_time_format, a:file.vimfiler__filetime))
        \ : datemark . a:file.vimfiler__filetime)
endfunction"}}}

function! s:get_datemark(file) "{{{
  if a:file.vimfiler__filetime !~ '^\d\+$'
    return '~'
  endif

  let time = localtime() - a:file.vimfiler__filetime
  if time < 86400
    " 60 * 60 * 24
    return '!'
  elseif time < 604800
    " 60 * 60 * 24 * 7
    return '#'
  else
    return '~'
  endif
endfunction"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker

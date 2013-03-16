"=============================================================================
" FILE: syntax/vimfiler.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 16 Mar 2013.
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

if version < 700
  syntax clear
elseif exists('b:current_syntax')
  finish
endif

syntax match   vimfilerDirectory         '^..$'

syntax match   vimfilerPrompt            '^\[in\]: .*$'
      \ contains=vimfilerSpecial,vimfilerCurrentDirectory
syntax match   vimfilerPromptUnSafe        '^! \[in\]: .*$'
      \ contains=vimfilerSpecial,vimfilerSpecialUnSafe,vimfilerCurrentDirectory
syntax match   vimfilerSpecialUnSafe       '^! ' contained
syntax match   vimfilerSpecial           '\[in\]:' contained
syntax match   vimfilerCurrentDirectory  '\s\zs.*$' contained contains=vimfilerMask
syntax match   vimfilerMask  '\[.*\]$' contained
syntax match   vimfilerFileLine          '\[.*\]$' contained

" Initialize icon patterns."{{{
let s:leaf_icon = vimfiler#util#escape_pattern(
      \ g:vimfiler_tree_leaf_icon)
let s:opened_icon = vimfiler#util#escape_pattern(
      \ g:vimfiler_tree_opened_icon)
let s:closed_icon = vimfiler#util#escape_pattern(
      \ g:vimfiler_tree_closed_icon)
let s:ro_file_icon = vimfiler#util#escape_pattern(
      \ g:vimfiler_readonly_file_icon)
let s:file_icon = vimfiler#util#escape_pattern(
      \ g:vimfiler_file_icon)
let s:marked_file_icon = vimfiler#util#escape_pattern(
      \ g:vimfiler_marked_file_icon)

execute 'syntax match   vimfilerMarkedFile'
      \ '''^\s*\%('  . s:leaf_icon .'\)*'
      \ . s:marked_file_icon . ' .*$'''

execute 'syntax match   vimfilerNormalFile'
      \ '''^\s*\%('.s:leaf_icon.'\)\?'.
      \ s:file_icon.'.*'' contains=vimfilerNonMark oneline'

execute 'syntax match   vimfilerOpendFile'
      \ '''^\s*\%('.s:leaf_icon.'\)\?'.
      \ s:opened_icon.'.*'' contains=vimfilerNonMark oneline'
execute 'syntax match   vimfilerClosedFile'
      \ '''^\s*\%('.s:leaf_icon.'\)\?'.
      \ s:closed_icon.'.*'' contains=vimfilerNonMark oneline'
execute 'syntax match   vimfilerROFile'
      \ '''^\s*\%('.s:leaf_icon.'\)\?'.
      \ s:ro_file_icon.'.*'' contains=vimfilerNonMark oneline'

execute 'syntax match   vimfilerNonMark'
      \ '''^\s*\%('.s:leaf_icon.'\)\?\%('.s:opened_icon.'\|'
      \ .s:closed_icon.'\|'.s:ro_file_icon.'\|'.s:file_icon.'\)'' contained'

unlet s:opened_icon
unlet s:closed_icon
unlet s:ro_file_icon
unlet s:file_icon
unlet s:marked_file_icon
"}}}

highlight def link vimfilerCurrentDirectory Identifier
highlight def link vimfilerMask Statement

highlight def link vimfilerSpecial Special
highlight def link vimfilerSpecialUnSafe Statement

highlight def link vimfilerNonMark Special
highlight def link vimfilerMarkedFile Type
highlight def link vimfilerDirectory Preproc

highlight def link vimfilerOpendFile Preproc
highlight def link vimfilerClosedFile Preproc
highlight def link vimfilerROFile Comment

let b:current_syntax = 'vimfiler'

" vim: foldmethod=marker

"=============================================================================
" FILE: syntax/vimfiler.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 13 Feb 2012.
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

let leaf_icon = vimfiler#util#escape_pattern(g:vimfiler_tree_leaf_icon)
let opened_icon = vimfiler#util#escape_pattern(g:vimfiler_tree_opened_icon)
let closed_icon = vimfiler#util#escape_pattern(g:vimfiler_tree_closed_icon)
let file_icon = vimfiler#util#escape_pattern(g:vimfiler_file_icon)
let marked_file_icon = vimfiler#util#escape_pattern(g:vimfiler_marked_file_icon)

syn match   vimfilerNonMarkedFile     '.*'
      \ contains=vimfilerNonMark,vimfilerTypeText,vimfilerTypeImage,vimfilerTypeArchive,
      \vimfilerTypeExecute,vimfilerTypeMultimedia,vimfilerTypeDirectory,vimfilerTypeSystem,vimfilerTypeLink,
      \vimfilerSize,vimfilerDate,vimfilerDateToday,vimfilerDateWeek
execute 'syn match   vimfilerMarkedFile'        '''^\s*\%('  . leaf_icon .'\)\?'
      \ . marked_file_icon . ' .*$'''
      \ 'contains=vimfilerDate,vimfilerDateToday,vimfilerDateWeek'
syn match   vimfilerDirectory         '^..$'

syn match   vimfilerPrompt            '^\[in\]: .*$'
      \ contains=vimfilerSpecial,vimfilerCurrentDirectory
syn match   vimfilerPromptUnSafe        '^! \[in\]: .*$'
      \ contains=vimfilerSpecial,vimfilerSpecialUnSafe,vimfilerCurrentDirectory
syn match   vimfilerSpecialUnSafe       '^! ' contained
syn match   vimfilerSpecial           '\[in\]:' contained
syn match   vimfilerCurrentDirectory  '\s\zs.*$' contained contains=vimfilerMask
syn match   vimfilerMask  '\[.*\]$' contained
syn match   vimfilerFileLine          '\[.*\]$' contained

syn match   vimfilerTypeText          '.*\[TXT\]' contained
syn match   vimfilerTypeImage         '.*\[IMG\]' contained
syn match   vimfilerTypeArchive       '.*\[ARC\]' contained
syn match   vimfilerTypeExecute       '.*\[EXE\]' contained
syn match   vimfilerTypeMultimedia    '.*\[MUL\]' contained
syn match   vimfilerTypeDirectory     '.*\[DIR\]' contained
syn match   vimfilerTypeSystem        '.*\[SYS\]' contained
syn match   vimfilerTypeLink          '.*\[LNK\]' contained

syn match   vimfilerSize              '\s\zs[[:digit:].]\+\s*[GMKB]' contained

" syn match   vimfilerNonMark         '^\s*|\?[+-]' contained
execute 'syn match   vimfilerNonMark'
      \ '''^\s*\%('. leaf_icon .'\)\?\%('. opened_icon . '\|'
      \ . closed_icon . '\|' . file_icon  .'\)'' contained'

syn match   vimfilerDate              '\s\zs#[^#]\+$' contains=vimfilerDateIgnore contained
syn match   vimfilerDateToday         '\s\zs\~[^~]\+$' contains=vimfilerDateIgnore contained
syn match   vimfilerDateWeek          '\s\zs![^!]\+$' contains=vimfilerDateIgnore contained
if has('conceal')
  " Supported conceal features.
  syn match   vimfilerDateIgnore        '[#~!]' contained conceal
else
  syn match   vimfilerDateIgnore        '[#~!]' contained
endif

if has('gui_running')
    hi vimfilerCurrentDirectory  guifg=#80ffff guibg=NONE
else
    hi def link vimfilerCurrentDirectory Identifier
endif
hi def link vimfilerMask Statement

hi def link vimfilerSpecial Special
hi def link vimfilerSpecialUnSafe Statement

hi def link vimfilerNonMark Special
"hi vimfilerMarkedFile  gui=REVERSE term=REVERSE
hi def link vimfilerMarkedFile Type
hi def link vimfilerDirectory Preproc
hi def link vimfilerSize Constant

hi def link vimfilerDateToday Statement
hi def link vimfilerDateWeek Special
hi def link vimfilerDate Identifier
hi def link vimfilerDateIgnore Ignore

hi def link vimfilerTypeText Constant
hi def link vimfilerTypeImage Type
hi def link vimfilerTypeArchive Special
hi def link vimfilerTypeExecute Statement
hi def link vimfilerTypeMultimedia Identifier
hi def link vimfilerTypeDirectory Preproc
hi def link vimfilerTypeSystem Comment
hi def link vimfilerTypeLink Comment

let b:current_syntax = 'vimfiler'

" vim: foldmethod=marker

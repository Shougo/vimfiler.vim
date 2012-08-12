"=============================================================================
" FILE: syntax/vimfiler.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 12 Aug 2012.
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

syntax match   vimfilerNonMarkedFile     '.*'
      \ contains=vimfilerNonMark,vimfilerTypeText,vimfilerTypeImage,
      \vimfilerTypeArchive,vimfilerTypeExecute,vimfilerTypeMultimedia,
      \vimfilerTypeDirectory,vimfilerTypeSystem,vimfilerTypeLink,
      \vimfilerSize,vimfilerDate,vimfilerDateToday,vimfilerDateWeek

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

syntax match   vimfilerTypeText          '.*\[TXT\]' contained
syntax match   vimfilerTypeImage         '.*\[IMG\]' contained
syntax match   vimfilerTypeArchive       '.*\[ARC\]' contained
syntax match   vimfilerTypeExecute       '.*\[EXE\]' contained
syntax match   vimfilerTypeMultimedia    '.*\[MUL\]' contained
syntax match   vimfilerTypeDirectory     '.*\[DIR\]' contained
syntax match   vimfilerTypeSystem        '.*\[SYS\]' contained
syntax match   vimfilerTypeLink          '.*\[LNK\]' contained

syntax match   vimfilerSize              '\s\zs[[:digit:].]\+\s*[GMKB]' contained

syntax match   vimfilerDate              '\s\zs#[^#]\+$' contains=vimfilerDateIgnore contained
syntax match   vimfilerDateToday         '\s\zs\~[^~]\+$' contains=vimfilerDateIgnore contained
syntax match   vimfilerDateWeek          '\s\zs![^!]\+$' contains=vimfilerDateIgnore contained
if has('conceal')
  " Supported conceal features.
  syntax match   vimfilerDateIgnore        '[#~!]' contained conceal
else
  syntax match   vimfilerDateIgnore        '[#~!]' contained
endif

highlight def link vimfilerCurrentDirectory Identifier
highlight def link vimfilerMask Statement

highlight def link vimfilerSpecial Special
highlight def link vimfilerSpecialUnSafe Statement

highlight def link vimfilerNonMark Special
highlight def link vimfilerMarkedFile Type
highlight def link vimfilerDirectory Preproc
highlight def link vimfilerSize Constant

highlight def link vimfilerDateToday Statement
highlight def link vimfilerDateWeek Special
highlight def link vimfilerDate Identifier
highlight def link vimfilerDateIgnore Ignore

highlight def link vimfilerTypeText Constant
highlight def link vimfilerTypeImage Type
highlight def link vimfilerTypeArchive Special
highlight def link vimfilerTypeExecute Statement
highlight def link vimfilerTypeMultimedia Identifier
highlight def link vimfilerTypeDirectory Preproc
highlight def link vimfilerTypeSystem Comment
highlight def link vimfilerTypeLink Comment

let b:current_syntax = 'vimfiler'

" vim: foldmethod=marker

"=============================================================================
" FILE: syntax/vimfiler.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 30 Oct 2010
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
elseif exists("b:current_syntax")
  finish
endif

syn match   VimFilerNonMarkedFile     '^-'
syn match   VimFilerMarkedFile        '^\* .*$'
syn match   VimFilerDirectory         '^..$'

syn match   VimFilerPrompt            '^\%(Current directory\|CD\): .*$'
      \ contains=VimFilerSpecial,VimFilerCurrentDirectory
syn match   VimFilerPromptSafe        '^\*u\%[nsafe]\* \%(Current directory\|CD\): .*$'
      \ contains=VimFilerSpecial,VimFilerSpecialSafe,VimFilerCurrentDirectory
syn match   VimFilerSpecialSafe       '^\*u\%[nsafe]\* ' contained
syn match   VimFilerSpecial           '\%(Current directory\|CD\):' contained
syn match   VimFilerCurrentDirectory  '\s\zs.*$' contained contains=VimFilerMask
syn match   VimFilerMask  '\[.*\]$' contained

syn match   VimFilerTypeText          '\%(\f\s\?\)\+\s\+\[TXT\]'
syn match   VimFilerTypeImage         '\%(\f\s\?\)\+\s\+\[IMG\]'
syn match   VimFilerTypeArchive       '\%(\f\s\?\)\+\s\+\[ARC\]'
syn match   VimFilerTypeExecute       '\%(\f\s\?\)\+\s\+\[EXE\]'
syn match   VimFilerTypeMultimedia    '\%(\f\s\?\)\+\s\+\[MUL\]'
syn match   VimFilerTypeDirectory     '\%(\f\s\?\)\+\s\+\[DIR\]'
syn match   VimFilerTypeSystem        '\%(\f\s\?\)\+\s\+\[SYS\]'
syn match   VimFilerTypeLink          '\%(\f\s\?\)\+\s\+\[LNK\]'

syn match   VimFilerSize              '\s\zs[0-9.]\a*\s'

syn match   VimFilerDate              '\s\zs#[[:digit:]/]\+\s\+\d\+:\d\+$' contains=VimFilerDateIgnore
syn match   VimFilerDateToday         '\s\zs\~[[:digit:]/]\+\s\+\d\+:\d\+$' contains=VimFilerDateIgnore
syn match   VimFilerDateWeek          '\s\zs![[:digit:]/]\+\s\+\d\+:\d\+$' contains=VimFilerDateIgnore
if has('conceal')
  " Supported conceal features.
  syn match   VimFilerDateIgnore        '[#~!]' contained conceal
else
  syn match   VimFilerDateIgnore        '[#~!]' contained
endif

if has('gui_running')
    hi VimFilerCurrentDirectory  gui=UNDERLINE guifg=#80ffff guibg=NONE
else
    hi def link VimFilerCurrentDirectory Identifier
endif
hi def link VimFilerMask Statement

hi def link VimFilerSpecial Special
hi def link VimFilerSpecialSafe Statement
hi def link VimFilerNonMarkedFile Special
"hi VimFilerMarkedFile  gui=REVERSE term=REVERSE
hi def link VimFilerMarkedFile Type
hi def link VimFilerDirectory Preproc
hi def link VimFilerSize Constant

hi def link VimFilerDateToday Statement
hi def link VimFilerDateWeek Special
hi def link VimFilerDate Identifier
hi def link VimFilerDateIgnore Ignore

hi def link VimFilerTypeText Constant
hi def link VimFilerTypeImage Type
hi def link VimFilerTypeArchive Special
hi def link VimFilerTypeExecute Statement
hi def link VimFilerTypeMultimedia Identifier
hi def link VimFilerTypeDirectory Preproc
hi def link VimFilerTypeSystem Comment
hi def link VimFilerTypeLink Comment

let b:current_syntax = "vimfiler"

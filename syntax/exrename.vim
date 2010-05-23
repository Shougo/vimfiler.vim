"=============================================================================
" FILE: syntax/exrename.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 23 May 2010
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

syn match   ExrenameTypeText          '^.*\[TXT\]'
syn match   ExrenameTypeImage         '^.*\[IMG\]'
syn match   ExrenameTypeArchive       '^.*\[ARC\]'
syn match   ExrenameTypeExecute       '^.*\[EXE\]'
syn match   ExrenameTypeMultimedia    '^.*\[MUL\]'
syn match   ExrenameTypeDirectory     '^.*\[DIR\]'
syn match   ExrenameTypeSystem        '^.*\[SYS\]'

syn match   ExrenameSize              '\s\zs[0-9.]\a*\s'

syn match   ExrenameDate              '\s\zs#[[:digit:]/]\+\s\+\d\+:\d\+$' contains=ExrenameDateIgnore
syn match   ExrenameDateToday         '\s\zs\~[[:digit:]/]\+\s\+\d\+:\d\+$' contains=ExrenameDateIgnore
syn match   ExrenameDateWeek          '\s\zs![[:digit:]/]\+\s\+\d\+:\d\+$' contains=ExrenameDateIgnore
syn match   ExrenameDateIgnore        '[#~!]' contained

hi def link ExrenameSize Constant
hi def link ExrenameDateToday Statement
hi def link ExrenameDateWeek Special
hi def link ExrenameDate Identifier
hi def link ExrenameDateIgnore Ignore

hi def link ExrenameTypeText Constant
hi def link ExrenameTypeImage Type
hi def link ExrenameTypeArchive Special
hi def link ExrenameTypeExecute Statement
hi def link ExrenameTypeMultimedia Identifier
hi def link ExrenameTypeDirectory Preproc
hi def link ExrenameTypeSystem Comment

let b:current_syntax = 'exrename'

"=============================================================================
" FILE: syntax/vimfiler.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>(Modified)
" Last Modified: 20 Jun 2010
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
" Version: 1.1, for Vim 7.0
"-----------------------------------------------------------------------------
" ChangeLog: "{{{
"   1.1:
"     - Added filetypes.
"     - Improved non marked files.
"
"   1.0:
"     - Initial version.
""}}}
"=============================================================================

if version < 700
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

syn match   VimFilerNonMarkedFile     '^-'
syn match   VimFilerMarkedFile        '^\* .*$'
syn match   VimFilerDirectory         '^..$'
syn match   VimFilerPrompt            '^Current directory: .*$'
syn match   VimFilerTypeText          '\%(\f\s\?\)\+\s\+\[TXT\]\s'
syn match   VimFilerTypeImage         '\%(\f\s\?\)\+\s\+\[IMG\]\s'
syn match   VimFilerTypeArchive       '\%(\f\s\?\)\+\s\+\[ARC\]\s'
syn match   VimFilerTypeExecute       '\%(\f\s\?\)\+\s\+\[EXE\]\s'
syn match   VimFilerTypeMultimedia    '\%(\f\s\?\)\+\s\+\[MUL\]\s'
syn match   VimFilerTypeDirectory     '\%(\f\s\?\)\+\s\+\[DIR\]\s'
syn match   VimFilerTypeSystem        '\%(\f\s\?\)\+\s\+\[SYS\]\s'
syn match   VimFilerSize              '\s[0-9.]\a*\s'
syn match   VimFilerDate              '\s\~.*$'
syn match   VimFilerDateToday         '\s\!.*$'
syn match   VimFilerDateWeek          '\s\#.*$'

if has('gui_running')
    hi VimFilerPrompt  gui=UNDERLINE guifg=#80ffff guibg=NONE
else
    hi def link FilerPrompt Identifier
endif
hi def link VimFilerNonMarkedFile Special
hi def link VimFilerMarkedFile Statement
hi def link VimFilerDirectory Preproc
hi def link VimFilerSize Constant
hi def link VimFilerDateToday Statement
hi def link VimFilerDateWeek Special
hi def link VimFilerDate Identifier

hi def link VimFilerTypeText Constant
hi def link VimFilerTypeImage Type
hi def link VimFilerTypeArchive Special
hi def link VimFilerTypeExecute Statement
hi def link VimFilerTypeMultimedia Identifier
hi def link VimFilerTypeDirectory Preproc
hi def link VimFilerTypeSystem Comment

let b:current_syntax = "vimfiler"

"=============================================================================
" FILE: vimshell.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 03 May 2010
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

if v:version < 700
  echoerr 'vimfiler does not work this version of Vim "' . v:version . '".'
  finish
elseif exists('g:loaded_vimfiler')
  finish
endif

let s:save_cpo = &cpo
set cpo&vim
let s:iswin = has('win32') || has('win64')

" Global options definition."{{{
if !exists('g:vimfiler_execute_file_list')
  let g:vimfiler_execute_file_list = {}
endif
if !exists('g:vimfiler_split_command')
  let g:vimfiler_split_command = 'split_nicely'
endif
if !exists('g:vimfiler_edit_command')
  let g:vimfiler_edit_command = 'edit_nicely'
endif
if !exists('g:vimfiler_pedit_command')
  let g:vimfiler_edit_command = 'pedit'
endif
if !exists('g:vimfiler_external_delete_command')
  if s:iswin
    let g:vimfiler_external_delete_command = 'rmdir /Q /S $srcs'
  else
    let g:vimfiler_external_delete_command = 'rm -R $srcs'
  endif
endif
if !exists('g:vimfiler_external_copy_command')
  if s:iswin
    let g:vimfiler_external_copy_command = 'xcopy /S /E /G /H /R /K /Y /I /Q $src $dest$srcdir'
  else
    let g:vimfiler_external_copy_command = 'cp -R $srcs $dest'
  endif
endif
if !exists('g:vimfiler_external_move_command')
  if s:iswin
    let g:vimfiler_external_move_command = 'move $src $dest'
  else
    let g:vimfiler_external_move_command = 'mv $srcs $dest'
  endif
endif
"}}}

" Plugin keymappings"{{{
nnoremap <silent> <Plug>(vimfiler_split_switch)  :<C-u>call vimfiler#switch_filer(1, '')<CR>
nnoremap <silent> <Plug>(vimfiler_split_create)  :<C-u>call vimfiler#create_filer(1, '')<CR>
nnoremap <silent> <Plug>(vimfiler_switch)  :<C-u>call vimfiler#switch_filer(0, '')<CR>
nnoremap <silent> <Plug>(vimfiler_create)  :<C-u>call vimfiler#create_filer(0, '')<CR>
"}}}

command! -nargs=? -complete=dir VimFiler call vimfiler#switch_filer(0, <q-args>)
command! -nargs=? -complete=dir VimFilerCreate call vimfiler#create_filer(0, <q-args>)

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_vimfiler = 1

" vim: foldmethod=marker

"=============================================================================
" FILE: vimshell.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 28 Jan 2010
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
" Version: 1.02, for Vim 7.0
"=============================================================================

if v:version < 700
    echoerr 'vimfiler does not work this version of Vim "' . v:version . '".'
    finish
elseif exists('g:loaded_vimfiler')
    finish
endif

let s:save_cpo = &cpo
set cpo&vim

" Global options definition."{{{
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

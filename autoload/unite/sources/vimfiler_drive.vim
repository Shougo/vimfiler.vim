"=============================================================================
" FILE: vimfiler/drive.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 22 Sep 2011.
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

function! unite#sources#vimfiler_drive#define()"{{{
  return s:source
endfunction"}}}

let s:source = {
      \ 'name' : 'vimfiler/drive',
      \ 'description' : 'candidates from vimfiler drive',
      \ 'default_action' : 'lcd',
      \ 'hooks' : {},
      \ 'is_listed' : 0,
      \ }

function! s:source.hooks.on_init(args, context)"{{{
  if &filetype !=# 'vimfiler'
    return
  endif

  if !exists('s:drives')
    if vimfiler#iswin()
      " Detect drives.
      let s:drives = filter(map(copy(g:vimfiler_detect_drives),
            \ 'v:val.":/"'), 'isdirectory(v:val)')
    else
      " Detect mounted drive.
      let s:drives = (has('macunix') || system('uname') =~? '^darwin') ?
            \ split(glob('/Volumes/*'), '\n') :
            \ split(glob('/mnt/*'), '\n') + split(glob('/media/*'), '\n')
    endif
  endif
endfunction"}}}

function! s:source.gather_candidates(args, context)"{{{
  return map(copy(s:drives), '{
        \ "word" : v:val,
        \ "action__path" : v:val,
        \ "action__directory" : v:val,
        \ "kind" : "directory",
        \ }')
endfunction"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker

"=============================================================================
" FILE: vimfiler/drive.vim
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

let g:vimfiler_detect_drives =
      \ get(g:, 'vimfiler_detect_drives', unite#util#is_windows() ? [
      \     'A:/', 'B:/', 'C:/', 'D:/', 'E:/', 'F:/', 'G:/',
      \     'H:/', 'I:/', 'J:/', 'K:/', 'L:/', 'M:/', 'N:/',
      \     'O:/', 'P:/', 'Q:/', 'R:/', 'S:/', 'T:/', 'U:/',
      \     'V:/', 'W:/', 'X:/', 'Y:/', 'Z:/'
      \ ] : [])

function! unite#sources#vimfiler_drive#define() "{{{
  return s:source
endfunction"}}}

let s:source = {
      \ 'name' : 'vimfiler/drive',
      \ 'description' : 'candidates from vimfiler drive',
      \ 'default_action' : 'lcd',
      \ 'is_listed' : 0,
      \ }

function! s:source.gather_candidates(args, context) "{{{
  if !exists('s:drives') || a:context.is_redraw
    " Detect mounted drive.
    let s:drives = copy(g:vimfiler_detect_drives)
    if unite#util#is_mac()
      let s:drives += split(glob('/Volumes/*'), '\n')
    elseif !unite#util#is_windows()
      let s:drives += split(glob('/mnt/*'), '\n')
            \ + split(glob('/media/*'), '\n')
    endif
    call filter(s:drives, 'isdirectory(v:val)')

    if !empty(unite#get_all_sources('ssh'))
      " Add network drive.
      let s:drives += map(unite#sources#ssh#complete_host('', '', 0),
            \ "'ssh://'.v:val.'/'")
    endif

    let s:drives = unite#util#uniq(s:drives)
  endif

  return map(copy(s:drives), "{
        \ 'word' : v:val,
        \ 'action__path' : v:val,
        \ 'action__directory' : v:val,
        \ 'kind' : (v:val =~ '^ssh://' ?
        \     'directory/ssh' : 'directory'),
        \ }")
endfunction"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker

"=============================================================================
" FILE: vimfiler/sort.vim
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

function! unite#sources#vimfiler_sort#define() "{{{
  return s:source
endfunction"}}}

let s:Cache = vimfiler#util#get_vital().import('System.Cache')

let s:source = {
      \ 'name' : 'vimfiler/sort',
      \ 'description' : 'candidates from vimfiler sort method',
      \ 'default_action' : 'sort',
      \ 'action_table' : {},
      \ 'hooks' : {},
      \ 'is_listed' : 0,
      \ }

function! s:source.hooks.on_init(args, context) "{{{
  if &filetype !=# 'vimfiler'
    return
  endif

  let a:context.source__sort = b:vimfiler.local_sort_type
endfunction"}}}

function! s:source.gather_candidates(args, context) "{{{
  if !has_key(a:context, 'source__sort')
    return []
  endif

  let cache_dir = vimfiler#variables#get_data_directory() . '/' . 'sort'
  let path = b:vimfiler.source.'/'.b:vimfiler.current_dir

  call unite#print_message(
        \ '[vimfiler/sort] Current sort type: ' . a:context.source__sort
        \ . (s:Cache.filereadable(cache_dir, path) ? '(saved)' : ''))
  call unite#print_message(
        \ '[vimfiler/sort] (Upper case is descending order)')

  return map(add([ 'none', 'size', 'extension', 'filename', 'time', 'manual',
        \ 'None', 'Size', 'Extension', 'Filename', 'Time', 'Manual'],
        \  s:Cache.filereadable(cache_dir, path) ? 'nosave' : 'save'), '{
        \ "word" : v:val,
        \ "action__sort" : v:val,
        \ }')
endfunction"}}}

" Actions "{{{
let s:action_table = {}

let s:action_table.sort = {
      \ 'description' : 'sort vimfiler items',
      \ }
function! s:action_table.sort.func(candidate) "{{{
  if &filetype != 'vimfiler'
    call unite#print_error('[vimfiler] Current vimfiler is not found.')
    return
  endif

  let cache_dir = vimfiler#variables#get_data_directory() . '/' . 'sort'
  let path = b:vimfiler.source.'/'.b:vimfiler.current_dir
  if a:candidate.action__sort ==# 'save' && !vimfiler#util#is_sudo()
    " Save current sort type.
    call s:Cache.writefile(cache_dir, path, [b:vimfiler.local_sort_type])
  elseif a:candidate.action__sort ==# 'nosave'
    " Nosave current sort type.
    if s:Cache.filereadable(cache_dir, path)
      call s:Cache.deletefile(cache_dir, path)
    endif
  else
    let b:vimfiler.local_sort_type = a:candidate.action__sort
    if s:Cache.filereadable(cache_dir, path) && !vimfiler#util#is_sudo()
      call s:Cache.writefile(cache_dir, path, [b:vimfiler.local_sort_type])
    endif

    call vimfiler#force_redraw_screen()
  endif
endfunction"}}}

let s:source.action_table['*'] = s:action_table
unlet! s:action_table
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker

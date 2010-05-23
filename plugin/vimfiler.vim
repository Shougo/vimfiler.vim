"=============================================================================
" FILE: vimshell.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 16 May 2010
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
if !exists('g:vimfiler_as_default_explorer')
  let g:vimfiler_as_default_explorer = 0
endif
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
  let g:vimfiler_pedit_command = 'pedit'
endif
if !exists('g:vimfiler_min_filename_width')
  let g:vimfiler_min_filename_width = 20
endif
if !exists('g:vimfiler_max_filename_width')
  let g:vimfiler_max_filename_width = 40
endif
if !exists('g:vimfiler_sort_type')
  let g:vimfiler_sort_type = 'none'
endif
if !exists('g:vimfiler_directory_display_top')
  let g:vimfiler_directory_display_top = 1
endif
if !exists('g:vimfiler_trashbox_directory')
  let g:vimfiler_trashbox_directory = expand('~/.vimfiler_trashbox')
endif
if !exists('g:vimfiler_detect_drives')
  let g:vimfiler_detect_drives = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 
            \ 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S',
            \ 'T', 'U', 'V', 'W', 'X', 'Y', 'Z']
endif
if !exists('g:vimfiler_external_delete_command')
  if s:iswin && !executable('rm')
    let g:vimfiler_external_delete_command = 'system rmdir /Q /S $srcs'
  else
    let g:vimfiler_external_delete_command = 'rm -r $srcs'
  endif
endif
if !exists('g:vimfiler_external_copy_file_command')
  if s:iswin && !executable('cp')
    let g:vimfiler_external_copy_file_command = 'system copy $src $dest'
  else
    let g:vimfiler_external_copy_file_command = 'cp $src $dest'
  endif
endif
if !exists('g:vimfiler_external_copy_directory_command')
  if s:iswin && !executable('cp')
    " Can't support.
    let g:vimfiler_external_copy_directory_command = ''
  else
    let g:vimfiler_external_copy_directory_command = 'cp -r $src $dest'
  endif
endif
if !exists('g:vimfiler_external_move_command')
  if s:iswin && !executable('mv')
    let g:vimfiler_external_move_command = 'move /Y $srcs $dest'
  else
    let g:vimfiler_external_move_command = 'mv $srcs $dest'
  endif
endif
"}}}

" Plugin keymappings"{{{
nnoremap <silent> <Plug>(vimfiler_split_switch)  :<C-u>call vimfiler#switch_filer('', ['split'])<CR>
nnoremap <silent> <Plug>(vimfiler_split_create)  :<C-u>call vimfiler#create_filer('', ['split'])<CR>
nnoremap <silent> <Plug>(vimfiler_switch)  :<C-u>call vimfiler#switch_filer('', [])<CR>
nnoremap <silent> <Plug>(vimfiler_create)  :<C-u>call vimfiler#create_filer('', [])<CR>
nnoremap <silent> <Plug>(vimfiler_simple)  :<C-u>call vimfiler#create_filer('', ['simple', 'split'])<CR>

" Edited file only.
nnoremap <silent> <Plug>(vimfiler_open_previous_file)     :<C-u>call vimfiler#mappings#open_previous_file()<CR>
nnoremap <silent> <Plug>(vimfiler_open_next_file)     :<C-u>call vimfiler#mappings#open_next_file()<CR>
"}}}

command! -nargs=? -complete=dir VimFiler call vimfiler#switch_filer(<q-args>, [])
command! -nargs=? -complete=dir VimFilerSimple call vimfiler#create_filer(<q-args>, ['simple', 'split'])
command! -nargs=? -complete=dir VimFilerCreate call vimfiler#create_filer(<q-args>, [])
command! VimFilerDetectDrives call vimfiler#detect_drives()

if g:vimfiler_as_default_explorer
  " Disable netrw.
  let g:loaded_netrwPlugin = 1
  
  augroup vimfiler-FileExplorer
    autocmd!
    autocmd VimEnter * silent! autocmd! FileExplorer
    autocmd BufEnter * call s:browse_check(expand('<amatch>'))
  augroup END
endif

function! s:browse_check(directory)
  if a:directory != '' && &filetype != 'vimfiler' && isdirectory(a:directory)
    silent! call vimfiler#create_filer(a:directory, ['overwrite'])
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_vimfiler = 1

" vim: foldmethod=marker

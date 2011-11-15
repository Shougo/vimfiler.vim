"=============================================================================
" FILE: vimshell.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 15 Nov 2011.
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

if v:version < 702
  echoerr 'vimfiler does not work this version of Vim "' . v:version . '".'
  finish
elseif exists('g:loaded_vimfiler')
  finish
elseif $SUDO_USER != ''
  echoerr '"sudo vim" is detected. Please use sudo.vim or other plugins instead.'
  echoerr 'vimfiler is disabled.'
  finish
endif

let s:save_cpo = &cpo
set cpo&vim
let s:iswin = has('win32') || has('win64')

" Global options definition."{{{
let g:vimfiler_as_default_explorer =
      \ get(g:, 'vimfiler_as_default_explorer', 0)
let g:vimfiler_execute_file_list =
      \ get(g:, 'vimfiler_execute_file_list', {})
let g:vimfiler_split_action =
      \ get(g:, 'vimfiler_split_action', 'vsplit')
let g:vimfiler_edit_action =
      \ get(g:, 'vimfiler_edit_action', 'open')
let g:vimfiler_preview_action =
      \ get(g:, 'vimfiler_preview_action', 'preview')
let g:vimfiler_min_filename_width =
      \ get(g:, 'vimfiler_min_filename_width', 30)
let g:vimfiler_max_filename_width =
      \ get(g:, 'vimfiler_max_filename_width', 80)
let g:vimfiler_sort_type =
      \ get(g:, 'vimfiler_sort_type', 'filename')
let g:vimfiler_directory_display_top =
      \ get(g:, 'vimfiler_directory_display_top', 1)
let g:vimfiler_detect_drives =
      \ get(g:, 'vimfiler_detect_drives', (has('win32') || has('win64')) ? [
      \     'A:/', 'B:/', 'C:/', 'D:/', 'E:/', 'F:/', 'G:/',
      \     'H:/', 'I:/', 'J:/', 'K:/', 'L:/', 'M:/', 'N:/',
      \     'O:/', 'P:/', 'Q:/', 'R:/', 'S:/', 'T:/', 'U:/',
      \     'V:/', 'W:/', 'X:/', 'Y:/', 'Z:/'
      \ ] : (has('macunix') || system('uname') =~? '^darwin') ?
      \ split(glob('/Volumes/*'), '\n') :
      \ split(glob('/mnt/*'), '\n') + split(glob('/media/*'), '\n'))

let g:vimfiler_max_directories_history =
      \ get(g:, 'vimfiler_max_directories_history', 10)
let g:vimfiler_safe_mode_by_default =
      \ get(g:, 'vimfiler_safe_mode_by_default', 1)
let g:vimfiler_time_format =
      \ get(g:, 'vimfiler_time_format', '%y/%m/%d %H:%M')
let g:vimfiler_data_directory =
      \ get(g:, 'vimfiler_data_directory', expand('~/.vimfiler'))
if !isdirectory(fnamemodify(g:vimfiler_data_directory, ':p'))
  call mkdir(iconv(fnamemodify(g:vimfiler_data_directory, ':p'),
        \    &encoding, &termencoding), 'p')
endif

" Set extensions.
let g:vimfiler_extensions =
      \ get(g:, 'vimfiler_extensions', {})
"}}}

" Plugin keymappings"{{{
nnoremap <silent> <Plug>(vimfiler_split_switch)
      \ :<C-u>call vimfiler#switch_filer('', { 'is_split' : 1 })<CR>
nnoremap <silent> <Plug>(vimfiler_split_create)
      \ :<C-u>call vimfiler#create_filer('', { 'is_split' : 1 })<CR>
nnoremap <silent> <Plug>(vimfiler_switch)
      \ :<C-u>call vimfiler#switch_filer('')<CR>
nnoremap <silent> <Plug>(vimfiler_create)
      \ :<C-u>call vimfiler#create_filer('')<CR>
nnoremap <silent> <Plug>(vimfiler_simple)
      \ :<C-u>call vimfiler#create_filer('', {'is_simple' : 1, 'split' : 1})<CR>
"}}}

command! -nargs=? -complete=customlist,vimfiler#complete VimFiler
      \ call vimfiler#switch_filer(<q-args>)
command! -nargs=? -complete=customlist,vimfiler#complete VimFilerDouble
      \ call vimfiler#create_filer(<q-args>,
      \   { 'is_double' : 1 })
command! -nargs=? -complete=customlist,vimfiler#complete VimFilerCreate
      \ call vimfiler#create_filer(<q-args>)
command! -nargs=? -complete=customlist,vimfiler#complete VimFilerSimple
      \ call vimfiler#create_filer(<q-args>,
      \   { 'is_simple' : 1, 'is_split' : 1 })
command! -nargs=? -complete=customlist,vimfiler#complete VimFilerSplit
      \ call vimfiler#create_filer(<q-args>,
      \   { 'is_split' : 1 })
command! -nargs=? -complete=customlist,vimfiler#complete VimFilerTab
      \ tabnew | call vimfiler#create_filer(<q-args>)
command! VimFilerDetectDrives call vimfiler#detect_drives()

if g:vimfiler_as_default_explorer
  augroup vimfiler-FileExplorer
    autocmd!
    autocmd BufEnter * call s:browse_check(expand('<amatch>'))
    autocmd BufReadCmd ??*:{*,*/*}  call vimfiler#handler#_event_handler('BufReadCmd')
    autocmd BufWriteCmd ??*:{*,*/*}  call vimfiler#handler#_event_handler('BufWriteCmd')
    autocmd FileAppendCmd ??*:{*,*/*}  call vimfiler#handler#_event_handler('FileAppendCmd')
    autocmd FileReadCmd ??*:{*,*/*}  call vimfiler#handler#_event_handler('FileReadCmd')
  augroup END

  " Define wrapper commands.
  command! -bang -bar -complete=customlist,vimfiler#complete -nargs=*
        \ Edit  edit<bang> <args>
  command! -bang -bar -complete=customlist,vimfiler#complete -nargs=*
        \ Read  read<bang> <args>
  command! -bang -bar -complete=customlist,vimfiler#complete -nargs=1
        \ Source  source<bang> <args>
  command! -bang -bar -complete=customlist,vimfiler#complete -nargs=* -range=%
        \ Write  <line1>,<line2>write<bang> <args>

  " Disable netrw.
  augroup FileExplorer
    autocmd!
  augroup END
endif

function! s:browse_check(path)
  " Disable netrw.
  augroup FileExplorer
    autocmd!
  augroup END

  let path = a:path
  " For ":edit ~".
  if fnamemodify(path, ':t') ==# '~'
    let path = '~'
  endif
  if isdirectory(expand(
        \ vimfiler#util#escape_file_searching(path)))
        \ && &filetype != 'vimfiler'
    call vimfiler#handler#_event_handler('BufReadCmd')
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_vimfiler = 1

" vim: foldmethod=marker

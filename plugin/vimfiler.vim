"=============================================================================
" FILE: vimfiler.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 14 Apr 2013.
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

if exists('g:loaded_vimfiler')
  finish
elseif v:version < 702
  echomsg 'vimfiler does not work this version of Vim "' . v:version . '".'
  finish
elseif $SUDO_USER != '' && $USER !=# $SUDO_USER
      \ && $HOME !=# expand('~'.$USER)
      \ && $HOME ==# expand('~'.$SUDO_USER)
  echohl Error
  echomsg 'vimfiler disabled: "sudo vim" is detected and $HOME is set to '
        \.'your user''s home. '
        \.'You may want to use the sudo.vim plugin, the "-H" option '
        \.'with "sudo" or set always_set_home in /etc/sudoers instead.'
  echohl None
  finish
endif

if exists(':NeoBundleDepends') "{{{
  NeoBundleDepends 'Shougo/unite.vim.git'
endif"}}}

let s:save_cpo = &cpo
set cpo&vim

" Global options definition. "{{{
let g:vimfiler_as_default_explorer =
      \ get(g:, 'vimfiler_as_default_explorer', 0)
let g:vimfiler_execute_file_list =
      \ get(g:, 'vimfiler_execute_file_list', {})
let g:vimfiler_split_action =
      \ get(g:, 'vimfiler_split_action', 'right')
let g:vimfiler_edit_action =
      \ get(g:, 'vimfiler_edit_action', 'open')
let g:vimfiler_preview_action =
      \ get(g:, 'vimfiler_preview_action', 'preview')
let g:vimfiler_sort_type =
      \ get(g:, 'vimfiler_sort_type', 'filename')
let g:vimfiler_directory_display_top =
      \ get(g:, 'vimfiler_directory_display_top', 1)
let g:vimfiler_split_rule =
      \ get(g:, 'vimfiler_split_rule', 'topleft')
let g:vimfiler_max_directories_history =
      \ get(g:, 'vimfiler_max_directories_history', 50)
let g:vimfiler_safe_mode_by_default =
      \ get(g:, 'vimfiler_safe_mode_by_default', 1)
let g:vimfiler_time_format =
      \ get(g:, 'vimfiler_time_format', '%y/%m/%d %H:%M')
let g:vimfiler_tree_leaf_icon =
      \ get(g:, 'vimfiler_tree_leaf_icon', '|')
let g:vimfiler_tree_opened_icon =
      \ get(g:, 'vimfiler_tree_opened_icon', '-')
let g:vimfiler_tree_closed_icon =
      \ get(g:, 'vimfiler_tree_closed_icon', '+')
let g:vimfiler_file_icon =
      \ get(g:, 'vimfiler_file_icon', ' ')
let g:vimfiler_readonly_file_icon =
      \ get(g:, 'vimfiler_readonly_file_icon', 'X')
let g:vimfiler_marked_file_icon =
      \ get(g:, 'vimfiler_marked_file_icon', '*')
let g:vimfiler_enable_auto_cd =
      \ get(g:, 'vimfiler_enable_auto_cd', 0)
let g:vimfiler_quick_look_command =
      \ get(g:, 'vimfiler_quick_look_command', '')
let g:vimfiler_default_columns =
      \ get(g:, 'vimfiler_default_columns', 'type:size:time')
let g:vimfiler_explorer_columns =
      \ get(g:, 'vimfiler_explorer_columns', 'type')
let g:vimfiler_data_directory =
      \ substitute(fnamemodify(get(
      \   g:, 'vimfiler_data_directory', '~/.vimfiler'),
      \  ':p'), '\\', '/', 'g')
if !isdirectory(g:vimfiler_data_directory)
  call mkdir(g:vimfiler_data_directory)
endif

" Set extensions.
let g:vimfiler_extensions =
      \ get(g:, 'vimfiler_extensions', {})
"}}}

" Plugin keymappings "{{{
nnoremap <silent> <Plug>(vimfiler_split_switch)
      \ :<C-u><SID>call_vimfiler({ 'split' : 1 }, '')<CR>
nnoremap <silent> <Plug>(vimfiler_split_create)
      \ :<C-u>VimFilerSplit<CR>
nnoremap <silent> <Plug>(vimfiler_switch)
      \ :<C-u>VimFiler<CR>
nnoremap <silent> <Plug>(vimfiler_create)
      \ :<C-u>VimFilerCreate<CR>
nnoremap <silent> <Plug>(vimfiler_simple)
      \ :<C-u>VimFilerSimple<CR>
"}}}

command! -nargs=? -complete=customlist,vimfiler#complete VimFiler
      \ call s:call_vimfiler({}, <q-args>)
command! -nargs=? -complete=customlist,vimfiler#complete VimFilerDouble
      \ call s:call_vimfiler({ 'double' : 1 }, <q-args>)
command! -nargs=? -complete=customlist,vimfiler#complete VimFilerCurrentDir
      \ call s:call_vimfiler({}, <q-args> . ' ' . getcwd())
command! -nargs=? -complete=customlist,vimfiler#complete VimFilerBufferDir
      \ call s:call_vimfiler({}, <q-args> . ' ' .
      \ vimfiler#util#substitute_path_separator(fnamemodify(bufname('%'), ':p:h')))
command! -nargs=? -complete=customlist,vimfiler#complete VimFilerCreate
      \ call s:call_vimfiler({ 'create' : 1 }, <q-args>)
command! -nargs=? -complete=customlist,vimfiler#complete VimFilerSimple
      \ call s:call_vimfiler({ 'simple' : 1, 'split' : 1, 'create' : 1 }, <q-args>)
command! -nargs=? -complete=customlist,vimfiler#complete VimFilerSplit
      \ call s:call_vimfiler({ 'split' : 1, }, <q-args>)
command! -nargs=? -complete=customlist,vimfiler#complete VimFilerTab
      \ tabnew | call s:call_vimfiler({ 'create' : 1 }, <q-args>)
command! -nargs=? -complete=customlist,vimfiler#complete VimFilerExplorer
      \ call s:call_vimfiler({ 'explorer' : 1, }, <q-args>)
command! VimFilerDetectDrives call vimfiler#detect_drives()
command! -nargs=1 VimFilerClose call vimfiler#mappings#close(<q-args>)

augroup vimfiler
  autocmd BufReadCmd ??*:{*,*/*}
        \ call vimfiler#handler#_event_handler('BufReadCmd')
  autocmd BufWriteCmd ??*:{*,*/*}
        \ call vimfiler#handler#_event_handler('BufWriteCmd')
  autocmd FileAppendCmd ??*:{*,*/*}
        \ call vimfiler#handler#_event_handler('FileAppendCmd')
  autocmd FileReadCmd ??*:{*,*/*}
        \ call vimfiler#handler#_event_handler('FileReadCmd')
  autocmd BufEnter,VimEnter,BufNew
        \ * call s:browse_check(expand('<amatch>'))
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

function! s:browse_check(path) "{{{
  if !g:vimfiler_as_default_explorer
        \ || bufnr('%') != expand('<abuf>')
        \ || a:path == ''
    return
  endif

  " Disable netrw.
  augroup FileExplorer
    autocmd!
  augroup END

  let path = a:path
  " For ":edit ~".
  if fnamemodify(path, ':t') ==# '~'
    let path = '~'
  endif

  if &filetype ==# 'vimfiler' && line('$') != 1
    return
  endif

  if isdirectory(vimfiler#util#expand(path))
    call vimfiler#handler#_event_handler('BufReadCmd')
  endif
endfunction"}}}

function! s:call_vimfiler(default, args) "{{{
  let args = []
  let options = a:default
  for arg in split(a:args, '\%(\\\@<!\s\)\+')
    let arg = substitute(arg, '\\\( \)', '\1', 'g')

    let arg_key = substitute(arg, '=\zs.*$', '', '')
    let matched_list = filter(copy(vimfiler#get_options()),
          \  'v:val ==# arg_key')
    for option in matched_list
      let key = substitute(substitute(option, '-', '_', 'g'),
            \ '=$', '', '')[1:]
      let options[key] = (option =~ '=$') ?
            \ arg[len(option) :] : 1
      break
    endfor

    if empty(matched_list)
      call add(args, arg)
    endif
  endfor

  call vimfiler#start(join(args), options)
endfunction"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_vimfiler = 1

" vim: foldmethod=marker

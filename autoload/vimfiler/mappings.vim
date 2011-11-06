"=============================================================================
" FILE: mappings.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 06 Nov 2011.
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

function! vimfiler#mappings#define_default_mappings()"{{{
  " Plugin keymappings"{{{
  nnoremap <buffer><expr> <Plug>(vimfiler_loop_cursor_down)
        \ (line('.') == line('$'))? 'gg' : 'j'
  nnoremap <buffer><expr> <Plug>(vimfiler_loop_cursor_up)
        \ (line('.') == 1)? 'G' : 'k'
  nnoremap <buffer><silent> <Plug>(vimfiler_redraw_screen)
        \ :<C-u>call vimfiler#force_redraw_screen()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_toggle_mark_current_line)
        \ :<C-u>call <SID>toggle_mark_current_line()<CR>j
  vnoremap <buffer><silent> <Plug>(vimfiler_toggle_mark_selected_lines)
        \ :<C-u>call <SID>toggle_mark_lines(getpos("'<")[1], getpos("'>")[1])<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_toggle_mark_all_lines)
        \ :<C-u>call <SID>toggle_mark_all_lines()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_clear_mark_all_lines)
        \ :<C-u>call <SID>clear_mark_all_lines()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_execute)
        \ :<C-u>call <SID>execute()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_execute_file)
        \ :<C-u>call <SID>execute_file()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_move_to_parent_directory)
        \ :<C-u>call vimfiler#mappings#cd('..')<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_move_to_home_directory)
        \ :<C-u>call vimfiler#mappings#cd('~')<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_move_to_root_directory)
        \ :<C-u>call vimfiler#mappings#cd('/')<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_move_to_drive)
        \ :<C-u>call <SID>move_to_drive()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_move_to_history_directory)
        \ :<C-u>call <SID>move_to_history_directory()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_toggle_visible_dot_files)
        \ :<C-u>call <SID>toggle_visible_dot_files()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_popup_shell)
        \ :<C-u>call <SID>popup_shell()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_edit_file)
        \ :<C-u>call vimfiler#mappings#do_action(g:vimfiler_edit_action)<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_split_edit_file)
        \ :<C-u>call vimfiler#mappings#do_action(g:vimfiler_split_action)<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_edit_binary_file)
        \ :<C-u>call <SID>edit_binary_file(0)<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_execute_external_filer)
        \ :<C-u>call <SID>execute_external_filer()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_execute_shell_command)
        \ :<C-u>call <SID>execute_shell_command()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_exit)
        \ :<C-u>call <SID>exit()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_help)
        \ :<C-u>call <SID>help()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_preview_file)
        \ :<C-u>call vimfiler#mappings#do_action(g:vimfiler_preview_action)<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_sync_with_current_vimfiler)
        \ :<C-u>call <SID>sync_with_current_vimfiler()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_sync_with_another_vimfiler)
        \ :<C-u>call <SID>sync_with_another_vimfiler()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_print_filename)
        \ :<C-u>call <SID>print_filename()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_set_current_mask)
        \ :<C-u>call <SID>set_current_mask()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_grep)
        \ :<C-u>call vimfiler#mappings#do_action('grep')<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_select_sort_type)
        \ :<C-u>call <SID>select_sort_type()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_move_to_other_window)
        \ :<C-u>call <SID>move_to_other_window()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_switch_vim_buffer_mode)
        \ :<C-u>call <SID>switch_vim_buffer_mode()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_restore_vimfiler_mode)
        \ :<C-u>call <SID>restore_vimfiler_mode()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_cd)
        \ :<C-u>call <SID>change_vim_current_dir(b:vimfiler.current_dir)<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_choose_action)
        \ :<C-u>call <SID>choose_action()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_toggle_safe_mode)
        \ :<C-u>call <SID>toggle_safe_mode()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_toggle_simple_mode)
        \ :<C-u>call <SID>toggle_simple_mode()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_pushd)
        \ :<C-u>call <SID>pushd()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_popd)
        \ :<C-u>call <SID>popd()<CR>
  nnoremap <buffer><silent><expr> <Plug>(vimfiler_smart_h)
        \ line('.') == 1 ? 'h' : ":\<C-u>call vimfiler#mappings#cd('..')\<CR>"
  nnoremap <buffer><silent><expr> <Plug>(vimfiler_smart_l)
        \ line('.') == 1 ? 'l' : ":\<C-u>call \<SID>execute()\<CR>"

  if b:vimfiler.is_safe_mode
    call s:unmapping_file_operations()
  else
    call s:mapping_file_operations()
  endif
  "}}}

  if exists('g:vimfiler_no_default_key_mappings')
        \ && g:vimfiler_no_default_key_mappings
    return
  endif

  nmap <buffer> <TAB> <Plug>(vimfiler_move_to_other_window)
  nmap <buffer> j <Plug>(vimfiler_loop_cursor_down)
  nmap <buffer> k <Plug>(vimfiler_loop_cursor_up)

  " Toggle mark.
  nmap <buffer> <C-l> <Plug>(vimfiler_redraw_screen)
  nmap <buffer> <Space> <Plug>(vimfiler_toggle_mark_current_line)
  vmap <buffer> <Space> <Plug>(vimfiler_toggle_mark_selected_lines)

  " Toggle marks in all lines.
  nmap <buffer> * <Plug>(vimfiler_toggle_mark_all_lines)
  " Clear marks in all lines.
  nmap <buffer> U <Plug>(vimfiler_clear_mark_all_lines)

  " Copy files.
  nmap <buffer> c <Plug>(vimfiler_copy_file)

  " Move files.
  nmap <buffer> m <Plug>(vimfiler_move_file)

  " Delete files.
  nmap <buffer> d <Plug>(vimfiler_delete_file)

  " Rename.
  nmap <buffer> r <Plug>(vimfiler_rename_file)

  " Make directory.
  nmap <buffer> K <Plug>(vimfiler_make_directory)

  " New file.
  nmap <buffer> N <Plug>(vimfiler_new_file)

  " Execute or change directory.
  nmap <buffer> <Enter> <Plug>(vimfiler_execute)
  nmap <buffer> l <Plug>(vimfiler_smart_l)

  nmap <buffer> x <Plug>(vimfiler_execute_file)

  " Move to directory.
  nmap <buffer> h <Plug>(vimfiler_smart_h)
  nmap <buffer> L <Plug>(vimfiler_move_to_drive)
  nmap <buffer> ~ <Plug>(vimfiler_move_to_home_directory)
  nmap <buffer> \ <Plug>(vimfiler_move_to_root_directory)
  nmap <buffer> <C-j> <Plug>(vimfiler_move_to_history_directory)

  nmap <buffer> gv <Plug>(vimfiler_execute_new_gvim)
  nmap <buffer> . <Plug>(vimfiler_toggle_visible_dot_files)
  nmap <buffer> H <Plug>(vimfiler_popup_shell)

  " Edit file.
  nmap <buffer> e <Plug>(vimfiler_edit_file)
  nmap <buffer> E <Plug>(vimfiler_split_edit_file)
  nmap <buffer> B <Plug>(vimfiler_edit_binary_file)

  " Choose action.
  nmap <buffer> a <Plug>(vimfiler_choose_action)

  nmap <buffer> ge <Plug>(vimfiler_execute_external_filer)
  nmap <buffer> t <Plug>(vimfiler_execute_external_command)
  nmap <buffer> ! <Plug>(vimfiler_execute_shell_command)
  nmap <buffer> q <Plug>(vimfiler_exit)
  nmap <buffer> ? <Plug>(vimfiler_help)
  nmap <buffer> v <Plug>(vimfiler_preview_file)
  nmap <buffer> o <Plug>(vimfiler_sync_with_current_vimfiler)
  nmap <buffer> O <Plug>(vimfiler_sync_with_another_vimfiler)
  nmap <buffer> <C-g> <Plug>(vimfiler_print_filename)
  nmap <buffer> M <Plug>(vimfiler_set_current_mask)
  nmap <buffer> gr <Plug>(vimfiler_grep)
  nmap <buffer> S <Plug>(vimfiler_select_sort_type)
  nmap <buffer> <C-v> <Plug>(vimfiler_switch_vim_buffer_mode)
  nmap <buffer> gc <Plug>(vimfiler_cd)
  nmap <buffer> gs <Plug>(vimfiler_toggle_safe_mode)
  nmap <buffer> gS <Plug>(vimfiler_toggle_simple_mode)

  " pushd/popd
  nmap <buffer> Y <Plug>(vimfiler_pushd)
  nmap <buffer> P <Plug>(vimfiler_popd)
endfunction"}}}

function! vimfiler#mappings#do_action(action)"{{{
  let marked_files = vimfiler#get_marked_files()
  if empty(marked_files)
    let marked_files = [ vimfiler#get_file(line('.')) ]
  endif

  call s:clear_mark_all_lines()

  " Execute action.
  let current_dir = b:vimfiler.current_dir
  call unite#mappings#do_action(a:action, marked_files, {
        \ 'vimfiler__current_directory' : current_dir,
        \ })
endfunction"}}}

function! vimfiler#mappings#cd(dir, ...)"{{{
  let save_history = get(a:000, 0, 1)

  let dir = vimfiler#util#substitute_path_separator(a:dir)

  if dir =~ ':'
    " Parse path.
    let [b:vimfiler.source, dir] = vimfiler#parse_path(dir)
  endif

  if dir == '..'
    if count(split(b:vimfiler.current_dir, '\zs'), '/') <= 1
      " Ignore.
      return
    endif

    let dir = fnamemodify(substitute(
          \ b:vimfiler.current_dir, '[/\\]$', '', ''), ':h')
  elseif dir == '/'
    " Root.
    let dir = vimfiler#iswin() ?
          \ matchstr(fnamemodify(b:vimfiler.current_dir, ':p'),
          \         '^\a\+:[/\\]') : dir
  elseif dir == '~'
    " Home.
    let dir = expand('~')
  elseif (vimfiler#iswin() && dir =~ '^//\|^\a\+:')
        \ || (!vimfiler#iswin() && dir =~ '^/')
    " Network drive or absolute path.
  else
    " Relative path.
    let dir = simplify(b:vimfiler.current_dir . dir)
  endif
  let dir = vimfiler#util#substitute_path_separator(dir)

  if vimfiler#iswin()
    let dir = vimfiler#resolve(dir)
  endif

  if dir !~ '/$'
    let dir .= '/'
  endif

  " Save current pos.
  let save_pos = getpos('.')
  let b:vimfiler.directory_cursor_pos[b:vimfiler.current_dir] = 
        \ deepcopy(save_pos)
  let prev_dir = b:vimfiler.current_dir
  let b:vimfiler.current_dir = dir

  " Save changed directories.
  if save_history
    call add(b:vimfiler.directories_history, prev_dir)

    let max_save = g:vimfiler_max_directories_history > 0 ?
          \ g:vimfiler_max_directories_history : 10
    if len(b:vimfiler.directories_history) >= max_save
      " Get last max_save num elements.
      let b:vimfiler.directories_history =
            \ b:vimfiler.directories_history[-max_save :]
    endif
  endif

  " Redraw.
  call vimfiler#force_redraw_screen()

  " Restore cursor pos.
  let save_pos[1] = 3
  call setpos('.', (has_key(b:vimfiler.directory_cursor_pos, dir) ?
        \ b:vimfiler.directory_cursor_pos[dir] : save_pos))
  normal! zb
endfunction"}}}

function! vimfiler#mappings#search_cursor(path)"{{{
  let max = line('$')
  let cnt = 1
  while cnt <= max
    if vimfiler#check_filename_line(getline(cnt))
          \ && vimfiler#get_file(cnt).action__path ==# a:path
      " Move cursor.
      call cursor(cnt, 0)
    endif

    let cnt += 1
  endwhile
endfunction"}}}

function! s:SID_PREFIX()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_\zeSID_PREFIX$')
endfunction

function! s:toggle_mark_current_line()"{{{
  if !vimfiler#check_filename_line()
    " Don't toggle.
    return
  endif

  let file = vimfiler#get_file(line('.'))
  let file.vimfiler__is_marked = !file.vimfiler__is_marked

  call vimfiler#redraw_screen()
endfunction"}}}
function! s:toggle_mark_all_lines()"{{{
  let max = line('$')
  let cnt = 1
  while cnt <= max
    let line = getline(cnt)
    if vimfiler#check_filename_line(line)
      " Toggle mark.
      let file = vimfiler#get_file(cnt)
      let file.vimfiler__is_marked = !file.vimfiler__is_marked
    endif

    let cnt += 1
  endwhile

  call vimfiler#redraw_screen()
endfunction"}}}
function! s:toggle_mark_lines(start, end)"{{{
  let cnt = a:start
  while cnt <= a:end
    let line = getline(cnt)
    if vimfiler#check_filename_line(line)
      " Toggle mark.
      let file = vimfiler#get_file(cnt)
      let file.vimfiler__is_marked = !file.vimfiler__is_marked
    endif

    let cnt += 1
  endwhile

  call vimfiler#redraw_screen()
endfunction"}}}
function! s:clear_mark_all_lines()"{{{
  let max = line('$')
  let cnt = 1
  while cnt <= max
    let line = getline(cnt)
    if vimfiler#check_filename_line(line)
      " Clear mark.

      let file = vimfiler#get_file(cnt)
      let file.vimfiler__is_marked = 0
    endif

    let cnt += 1
  endwhile
  call vimfiler#redraw_screen()
endfunction"}}}
function! s:execute()"{{{
  let line = getline('.')
  let filename = vimfiler#get_filename(line('.'))
  if filename != '..' && !vimfiler#check_filename_line()
    let cursor_line = matchstr(line[: col('.') - 1],
          \ ' Current directory: \zs.*')
    if cursor_line != ''
      " Change current directory.
      let cursor_next = matchstr(line[col('.') :], '.\{-}\ze[/\\]')

      call vimfiler#mappings#cd(cursor_line . cursor_next)
    endif

    return
  endif

  let filename = vimfiler#resolve(filename)

  if isdirectory(filename)
    " Change directory.
    call vimfiler#mappings#cd(filename)
  else
    call unite#start([['vimfiler/execute']], {'immediately' : 1})
  endif
endfunction"}}}
function! s:execute_file()"{{{
  if !vimfiler#check_filename_line()
    call s:execute_external_filer()
    return
  endif

  let file = vimfiler#get_file(line('.'))

  " Execute cursor file.
  call unite#mappings#do_action('vimfiler__execute', [file], {
        \ 'vimfiler__current_directory' : b:vimfiler.current_dir,
        \ })
endfunction"}}}
function! s:move_to_other_window()"{{{
  if winnr('$') == 1
    " Create another vimfiler.
    call vimfiler#create_filer(b:vimfiler.current_dir,
          \ b:vimfiler.is_simple ?
          \ { 'is_split' : 1, 'is_simple' : 1 } : { 'is_split' : 1 })
    let s:last_vimfiler_bufnr = bufnr('%')
    wincmd w
    call vimfiler#force_redraw_screen()
  endif

  wincmd w
endfunction"}}}
function! s:print_filename()"{{{
  let filename = vimfiler#get_filename(line('.'))
  if filename != '..' && !vimfiler#check_filename_line()
    let filename = matchstr(getline('.'),
          \ ' Current directory: \zs.*\ze[/\\]')
  endif

  echo filename
endfunction"}}}

function! s:move_to_drive()"{{{
  call unite#start([['vimfiler/drive']])
endfunction"}}}
function! s:move_to_history_directory()"{{{
  call unite#start([['vimfiler/history']])
endfunction"}}}
function! s:pushd()"{{{
  call unite#sources#vimfiler_popd#pushd()
endfunction"}}}
function! s:popd()"{{{
  call unite#start([['vimfiler/popd']])
endfunction"}}}

function! s:toggle_visible_dot_files()"{{{
  let b:vimfiler.is_visible_dot_files = !b:vimfiler.is_visible_dot_files
  call vimfiler#force_redraw_screen()
endfunction"}}}
function! s:popup_shell()"{{{
  let files = vimfiler#get_escaped_marked_files()
  call s:clear_mark_all_lines()

  let dummy_files = unite#get_vimfiler_candidates(
        \ [['file', b:vimfiler.current_dir]], {
        \ 'vimfiler__is_dummy' : 1,
        \ 'vimfiler__files' : files,
        \ 'vimfiler__current_directory' : b:vimfiler.current_dir,
        \ })
  if empty(dummy_files)
    return
  endif

  " Execute shell.
  call unite#mappings#do_action('vimfiler__shell', dummy_files, {
        \ 'vimfiler__current_directory' : b:vimfiler.current_dir,
        \ })
endfunction"}}}
function! s:edit_binary_file(is_split)"{{{
  if !vimfiler#check_filename_line()
    return
  endif

  if !exists(':Vinarise')
    call vimfiler#print_error('vinarise is not found. Please install it.')
    return
  endif

  Vinarise `=vimfiler#get_filename(line('.'))`
endfunction"}}}
function! s:execute_shell_command()"{{{
  echo 'Marked files:'
  echohl Type | echo join(vimfiler#get_marked_filenames(), "\n") | echohl NONE

  let command = input('Input shell command: ', '', 'shellcmd')
  redraw
  if command == ''
    echo 'Canceled.'
    return
  endif

  let special = matchstr(command,
        \'\s\+\zs[*?]\ze\%([;|[:space:]]\|$\)')
  if special == '*'
    let command = substitute(command,
        \'\s\+\zs[*]\ze\%([;|[:space:]]\|$\)',
        \ join(vimfiler#get_escaped_marked_files()), 'g')
  else
    let base_command = command
    let command = ''
    for file in vimfiler#get_escaped_marked_files()
      if special == '?'
        let command .= substitute(base_command,
              \'\s\+\zs[?]\ze\%([;|[:space:]]\|$\)', file, 'g') . '; '
      else
        let command .= base_command . ' '  . file . '; '
      endif
    endfor
  endif

  let dummy_files = unite#get_vimfiler_candidates(
        \ [['file', b:vimfiler.current_dir]], {
        \ 'vimfiler__is_dummy' : 1,
        \ 'vimfiler__command' : command,
        \ 'vimfiler__current_directory' : b:vimfiler.current_dir,
        \ })
  if empty(dummy_files)
    return
  endif

  " Execute shell command.
  call unite#mappings#do_action('vimfiler__shellcmd', dummy_files, {
        \ 'vimfiler__current_directory' : b:vimfiler.current_dir,
        \ })
  silent call s:clear_mark_all_lines()
endfunction"}}}
function! s:exit()"{{{
  let vimfiler_buf = bufnr('%')
  " Switch buffer.
  if winnr('$') != 1
    close
  else
    call s:custom_alternate_buffer()
  endif
  silent execute 'bdelete!' vimfiler_buf
endfunction"}}}
function! s:sync_with_current_vimfiler()"{{{
  " Search vimfiler window.
  if !vimfiler#exists_another_vimfiler()
    call vimfiler#create_filer(b:vimfiler.current_dir,
          \ b:vimfiler.is_simple ?
          \ { 'is_split' : 1, 'is_simple' : 1 } : { 'is_split' : 1 })
    let s:last_vimfiler_bufnr = bufnr('%')
  else
    " Change another vimfiler directory.
    let current_dir = b:vimfiler.current_dir
    execute vimfiler#winnr_another_vimfiler() . 'wincmd w'
    call vimfiler#mappings#cd(current_dir)
  endif

  wincmd p
  call vimfiler#redraw_screen()
endfunction"}}}
function! s:sync_with_another_vimfiler()"{{{
  " Search vimfiler window.
  if !vimfiler#exists_another_vimfiler()
    call vimfiler#create_filer(b:vimfiler.current_dir,
          \ b:vimfiler.is_simple ?
          \ { 'is_split' : 1, 'is_simple' : 1 } : { 'is_split' : 1 })
    let s:last_vimfiler_bufnr = bufnr('%')
    let b:vimfiler.another_vimfiler_bufnr = s:last_vimfiler_bufnr
    wincmd p
    call vimfiler#redraw_screen()
  else
    " Change current vimfiler directory.
    call vimfiler#mappings#cd(vimfiler#get_another_vimfiler().current_dir)
  endif
endfunction"}}}
function! s:choose_action()"{{{
  let marked_files = vimfiler#get_marked_files()
  if empty(marked_files)
    let marked_files = [ vimfiler#get_file(line('.')) ]
  endif

  call unite#mappings#_choose_action(marked_files)
endfunction"}}}

" File operations.
function! s:move()"{{{
  let marked_files = vimfiler#get_marked_files()
  if empty(marked_files)
    " Mark current line.
    call s:toggle_mark_current_line()
    return
  endif

  if !unite#util#input_yesno('Really move files?')
    redraw
    echo 'Canceled.'
    return
  endif

  " Get destination directory.
  let dest_dir = vimfiler#exists_another_vimfiler() ?
        \ vimfiler#get_another_vimfiler().current_dir : ''

  if dest_dir ==# b:vimfiler.current_dir
    " Rename.
    call s:rename()
    return
  endif

  " Execute move.
  call unite#mappings#do_action('vimfiler__move', marked_files, {
        \ 'action__directory' : dest_dir,
        \ 'vimfiler__current_directory' : b:vimfiler.current_dir,
        \ })
  call s:clear_mark_all_lines()
  silent call vimfiler#force_redraw_all_vimfiler()
endfunction"}}}
function! s:copy()"{{{
  let marked_files = vimfiler#get_marked_files()
  if empty(marked_files)
    " Mark current line.
    call s:toggle_mark_current_line()
    return
  endif

  " Get destination directory.
  let dest_dir = vimfiler#exists_another_vimfiler() ?
        \ vimfiler#get_another_vimfiler().current_dir : ''

  " Execute copy.
  call unite#mappings#do_action('vimfiler__copy', marked_files, {
        \ 'action__directory' : dest_dir,
        \ 'vimfiler__current_directory' : b:vimfiler.current_dir,
        \ })
  call s:clear_mark_all_lines()
  silent call vimfiler#force_redraw_all_vimfiler()
endfunction"}}}
function! s:delete()"{{{
  let marked_files = vimfiler#get_marked_files()
  if empty(marked_files)
    " Mark current line.
    call s:toggle_mark_current_line()
    return
  endif

  if !unite#util#input_yesno('Really force delete files?')
    redraw
    echo 'Canceled.'
    return
  endif

  " Execute delete.
  call unite#mappings#do_action('vimfiler__delete', marked_files, {
        \ 'vimfiler__current_directory' : b:vimfiler.current_dir,
        \ })
  call s:clear_mark_all_lines()
  silent call vimfiler#force_redraw_all_vimfiler()
endfunction"}}}
function! s:rename()"{{{
  if !vimfiler#check_filename_line()
    return
  endif

  let marked_files = vimfiler#get_marked_filenames()
  if !empty(marked_files)
    " Extended rename.
    call vimfiler#exrename#create_buffer(vimfiler#get_marked_files())
    return
  endif

  let file = vimfiler#get_file(line('.'))
  call unite#mappings#do_action('vimfiler__rename', [file], {
        \ 'vimfiler__current_directory' : b:vimfiler.current_dir,
        \ })
  silent call vimfiler#force_redraw_all_vimfiler()
endfunction"}}}
function! s:make_directory()"{{{
  let dummy_files = unite#get_vimfiler_candidates(
        \ [['file', b:vimfiler.current_dir]], {
        \ 'vimfiler__is_dummy' : 1,
        \ 'vimfiler__current_directory' : b:vimfiler.current_dir,
        \ })
  if empty(dummy_files)
    return
  endif

  " Execute mkdir action.
  call unite#mappings#do_action('vimfiler__mkdir', dummy_files, {
        \ 'vimfiler__current_directory' : b:vimfiler.current_dir,
        \ })

  silent call vimfiler#force_redraw_all_vimfiler()
endfunction"}}}
function! s:new_file()"{{{
  let dummy_files = unite#get_vimfiler_candidates(
        \ [['file', b:vimfiler.current_dir]], {
        \ 'vimfiler__is_dummy' : 1,
        \ 'vimfiler__current_directory' : b:vimfiler.current_dir,
        \ })
  if empty(dummy_files)
    continue
  endif

  " Make new file.
  call unite#mappings#do_action('vimfiler__newfile', dummy_files, {
        \ 'vimfiler__current_directory' : b:vimfiler.current_dir,
        \ })

  silent call vimfiler#force_redraw_all_vimfiler()
endfunction"}}}

function! s:set_current_mask()"{{{
  call unite#start([['vimfiler/mask']], { 'start_insert' : 1 })
endfunction"}}}
function! s:select_sort_type()"{{{
  call unite#start([['vimfiler/sort']])
endfunction"}}}
function! s:switch_vim_buffer_mode()"{{{
  redir => nmaps
  silent nmap <buffer>
  redir END

  let b:vimfiler.mapdict = {}
  for map in split(nmaps, '\n')
    let lhs = split(map)[1]
    let rhs = join(split(map)[2: ])[1:]
    if rhs =~ '^<Plug>(vimfiler_'
      let b:vimfiler.mapdict[lhs] = rhs
      execute 'nunmap <buffer>' lhs
    endif
  endfor

  nmap <buffer> <ESC> <Plug>(vimfiler_restore_vimfiler_mode)

  echo 'Switched vim buffer mode'
endfunction"}}}
function! s:restore_vimfiler_mode()"{{{
  for [lhs, rhs] in items(b:vimfiler.mapdict)
    execute 'nmap <buffer>' lhs rhs
  endfor

  echo 'Switched vimfiler mode'
endfunction"}}}
function! s:help()"{{{
  call unite#start([['mapping']])
endfunction"}}}
function! s:execute_external_filer()"{{{
  let dummy_files = unite#get_vimfiler_candidates(
        \ [['file', b:vimfiler.current_dir]], {
        \ 'vimfiler__is_dummy' : 1,
        \ 'vimfiler__current_directory' : b:vimfiler.current_dir,
        \ })
  if empty(dummy_files)
    return
  endif

  " Execute current directory.
  call unite#mappings#do_action('vimfiler__execute', dummy_files, {
        \ 'vimfiler__current_directory' : b:vimfiler.current_dir,
        \ })
endfunction"}}}
function! s:change_vim_current_dir(directory)"{{{
  let dummy_files = unite#get_vimfiler_candidates(
        \ [['file', a:directory]], {
        \ 'vimfiler__is_dummy' : 1,
        \ 'vimfiler__current_directory' : b:vimfiler.current_dir,
        \ })
  if empty(dummy_files)
    return
  endif

  " Execute cd.
  call unite#mappings#do_action('cd', dummy_files, {
        \ 'vimfiler__current_directory' : b:vimfiler.current_dir,
        \ })
endfunction"}}}

" For safe mode.
function! s:toggle_safe_mode()"{{{
  let b:vimfiler.is_safe_mode = !b:vimfiler.is_safe_mode
  echo 'Safe mode is ' . (b:vimfiler.is_safe_mode ? 'enabled' : 'disabled')
  call vimfiler#redraw_prompt()

  if b:vimfiler.is_safe_mode
    call s:unmapping_file_operations()
  else
    call s:mapping_file_operations()
  endif
endfunction"}}}
function! s:mapping_file_operations()"{{{
  nnoremap <buffer><silent> <Plug>(vimfiler_copy_file)  :<C-u>call <SID>copy()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_move_file)  :<C-u>call <SID>move()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_delete_file)  :<C-u>call <SID>delete()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_rename_file)  :<C-u>call <SID>rename()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_make_directory)  :<C-u>call <SID>make_directory()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_new_file)  :<C-u>call <SID>new_file()<CR>
endfunction"}}}
function! s:unmapping_file_operations()"{{{
  nnoremap <buffer><silent> <Plug>(vimfiler_copy_file)  :<C-u>call <SID>disable_operation()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_move_file)  :<C-u>call <SID>disable_operation()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_delete_file)  :<C-u>call <SID>disable_operation()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_rename_file)  :<C-u>call <SID>disable_operation()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_make_directory)  :<C-u>call <SID>disable_operation()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_new_file)  :<C-u>call <SID>disable_operation()<CR>
endfunction"}}}
function! s:disable_operation()"{{{
  call vimfiler#print_error('In safe mode, this operation is disabled.')
endfunction"}}}

function! s:custom_alternate_buffer()"{{{
  if bufnr('%') != bufnr('#') && buflisted(bufnr('#'))
    buffer #
  else
    let cnt = 0
    let pos = 1
    let current = 0
    while pos <= bufnr('$')
      if buflisted(pos)
        if pos == bufnr('%')
          let current = cnt
        endif

        let cnt += 1
      endif

      let pos += 1
    endwhile

    if current > cnt / 2
      bprevious
    else
      bnext
    endif
  endif

  silent call vimfiler#force_redraw_all_vimfiler()
endfunction"}}}

function! s:toggle_simple_mode()"{{{
  let b:vimfiler.is_simple = !b:vimfiler.is_simple
  call vimfiler#redraw_screen()
  echo 'Simple mode is ' . (b:vimfiler.is_simple ? 'enabled' : 'disabled')
endfunction"}}}

" vim: foldmethod=marker

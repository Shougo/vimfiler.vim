"=============================================================================
" FILE: mappings.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 03 Jun 2011.
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
  nnoremap <buffer><expr> <Plug>(vimfiler_loop_cursor_down)  (line('.') == line('$'))? 'gg' : 'j'
  nnoremap <buffer><expr> <Plug>(vimfiler_loop_cursor_up)  (line('.') == 1)? 'G' : 'k'
  nnoremap <buffer><silent> <Plug>(vimfiler_redraw_screen)  :<C-u>call vimfiler#force_redraw_screen()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_toggle_mark_current_line)  :<C-u>call <SID>toggle_mark_current_line()<CR>j
  vnoremap <buffer><silent> <Plug>(vimfiler_toggle_mark_selected_lines)  :<C-u>call <SID>toggle_mark_lines(getpos("'<")[1], getpos("'>")[1])<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_toggle_mark_all_lines)  :<C-u>call <SID>toggle_mark_all_lines()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_clear_mark_all_lines)  :<C-u>call <SID>clear_mark_all_lines()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_execute)  :<C-u>call <SID>mappings_caller('execute')<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_execute_file)  :<C-u>call <SID>mappings_caller('execute_file')<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_move_to_up_directory)  :<C-u>call vimfiler#internal_commands#cd('..')<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_move_to_home_directory)  :<C-u>call vimfiler#internal_commands#cd('~')<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_move_to_root_directory)  :<C-u>call vimfiler#internal_commands#cd('/')<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_move_to_trashbox_directory)  :<C-u>call vimfiler#internal_commands#cd(g:vimfiler_trashbox_directory)<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_move_to_drive)  :<C-u>call <SID>mappings_caller('move_to_drive')<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_move_to_history_forward)   :<C-u>call <SID>history_forward()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_move_to_history_back)      :<C-u>call <SID>history_back()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_jump_to_directory)  :<C-u>call <SID>mappings_caller('jump_to_directory')<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_jump_to_history_directory)  :<C-u>call <SID>mappings_caller('jump_to_history_directory')<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_execute_new_gvim)  :<C-u>call vimfiler#internal_commands#gexe('gvim')<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_toggle_visible_dot_files)  :<C-u>call <SID>toggle_visible_dot_files()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_popup_shell)  :<C-u>call <SID>mappings_caller('popup_shell')<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_edit_file)  :<C-u>call <SID>edit_file(0)<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_split_edit_file)  :<C-u>call <SID>edit_file(1)<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_edit_binary_file)  :<C-u>call <SID>edit_binary_file(0)<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_execute_external_filer)  :<C-u>call vimfiler#internal_commands#open(b:vimfiler.current_dir)<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_execute_external_command)  :<C-u>call <SID>mappings_caller('execute_external_command')<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_execute_shell_command)  :<C-u>call <SID>mappings_caller('execute_shell_command')<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_exit)  :<C-u>call <SID>exit()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_help)  :<C-u>nnoremap <buffer><CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_preview_file)  :<C-u>call <SID>preview_file()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_sync_with_current_vimfiler)  :<C-u>call <SID>sync_with_current_vimfiler()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_sync_with_another_vimfiler)  :<C-u>call <SID>sync_with_another_vimfiler()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_print_filename)  :<C-u>echo vimfiler#get_filename(line('.'))<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_paste_from_clipboard)  :<C-u>call <SID>paste_from_clipboard()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_set_current_mask)  :<C-u>call <SID>set_current_mask()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_grep)  :<C-u>call <SID>mappings_caller('grep')<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_select_sort_type)  :<C-u>call <SID>select_sort_type()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_move_to_other_window)  :<C-u>call <SID>move_to_other_window()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_switch_vim_buffer_mode)  :<C-u>call <SID>switch_vim_buffer_mode()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_restore_vimfiler_mode)  :<C-u>call <SID>restore_vimfiler_mode()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_cd)  :<C-u>call <SID>cd()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_toggle_safe_mode)  :<C-u>call <SID>toggle_safe_mode()<CR>
  nnoremap <buffer><silent><expr> <Plug>(vimfiler_smart_h)  line('.') == 1 ? 'h' : ":\<C-u>call vimfiler#internal_commands#cd('..')\<CR>"
  nnoremap <buffer><silent><expr> <Plug>(vimfiler_smart_l)  line('.') == 1 ? 'l' : ":\<C-u>call \<SID>mappings_caller('execute')\<CR>"

  if b:vimfiler.is_safe_mode
    call s:unmapping_file_operations()
  else
    call s:mapping_file_operations()
  endif
  "}}}

  if exists('g:vimfiler_no_default_key_mappings') && g:vimfiler_no_default_key_mappings
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
  nmap <buffer> D <Plug>(vimfiler_force_delete_file)

  " Restore.
  nmap <buffer> u <Plug>(vimfiler_restore_from_trashbox)

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
  nmap <buffer> J <Plug>(vimfiler_jump_to_directory)
  nmap <buffer> ~ <Plug>(vimfiler_move_to_home_directory)
  nmap <buffer> $ <Plug>(vimfiler_move_to_trashbox_directory)
  nmap <buffer> \ <Plug>(vimfiler_move_to_root_directory)
  nmap <buffer> <C-p> <Plug>(vimfiler_move_to_history_back)
  nmap <buffer> <C-n> <Plug>(vimfiler_move_to_history_forward)
  nmap <buffer> <C-j> <Plug>(vimfiler_jump_to_history_directory)

  nmap <buffer> gv <Plug>(vimfiler_execute_new_gvim)
  nmap <buffer> . <Plug>(vimfiler_toggle_visible_dot_files)
  nmap <buffer> H <Plug>(vimfiler_popup_shell)

  " Edit file.
  nmap <buffer> e <Plug>(vimfiler_edit_file)
  nmap <buffer> E <Plug>(vimfiler_split_edit_file)
  nmap <buffer> B <Plug>(vimfiler_edit_binary_file)

  nmap <buffer> ge <Plug>(vimfiler_execute_external_filer)
  nmap <buffer> t <Plug>(vimfiler_execute_external_command)
  nmap <buffer> ! <Plug>(vimfiler_execute_shell_command)
  nmap <buffer> q <Plug>(vimfiler_exit)
  nmap <buffer> ? <Plug>(vimfiler_help)
  nmap <buffer> p <Plug>(vimfiler_paste_from_clipboard)
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
endfunction"}}}

" vimfiler key-mappings functions.
function! vimfiler#mappings#open_previous_file()"{{{
  if !exists('b:vimfiler')
    return
  endif
  
  let i = 0
  let l:bufname = fnamemodify(bufname('%'), ':p')
  for l:file in b:vimfiler.current_files
    if l:file.name == l:bufname
      " Get next file.
      let i -= 1
      while i >= 0
        let l:filetype = vimfiler#get_filetype(b:vimfiler.current_files[i].name)
        if l:filetype == '     ' || l:filetype == '[TXT]'
          let l:vimfiler_save = b:vimfiler
          edit `=b:vimfiler.current_files[i].name`
          let b:vimfiler = l:vimfiler_save
          return
        endif

        let i -= 1
      endwhile
      
      break
    endif

    let i += 1
  endfor
endfunction"}}}
function! vimfiler#mappings#open_next_file()"{{{
  if !exists('b:vimfiler')
    return
  endif
  
  let i = 0
  let max = len(b:vimfiler.current_files)
  let l:bufname = fnamemodify(bufname('%'), ':p')
  for l:file in b:vimfiler.current_files
    if l:file.name == l:bufname
      " Get next file.
      let i += 1
      while i < max
        let l:filetype = vimfiler#get_filetype(b:vimfiler.current_files[i].name)
        if l:filetype == '     ' || l:filetype == '[TXT]'
          let l:vimfiler_save = b:vimfiler
          edit `=b:vimfiler.current_files[i].name`
          let b:vimfiler = l:vimfiler_save
          return
        endif

        let i += 1
      endwhile

      break
    endif

    let i += 1
  endfor
endfunction"}}}

function! s:SID_PREFIX()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_\zeSID_PREFIX$')
endfunction

function! s:mappings_caller(funcname)"{{{
  let l:current_dir = getcwd()
  call vimfiler#cd(b:vimfiler.current_dir)

  call call(s:SID_PREFIX().a:funcname, [])

  call vimfiler#cd(l:current_dir)
endfunction"}}}

function! s:toggle_mark_current_line()"{{{
  if !vimfiler#check_filename_line()
    " Don't toggle.
    return
  endif

  let l:file = vimfiler#get_file(line('.'))
  let l:file.is_marked = !l:file.is_marked
  
  call vimfiler#redraw_screen()
endfunction"}}}
function! s:toggle_mark_all_lines()"{{{
  let l:max = line('$')
  let l:cnt = 1
  while l:cnt <= l:max
    let l:line = getline(l:cnt)
    if vimfiler#check_filename_line(l:line)
      " Toggle mark.
      let l:file = vimfiler#get_file(l:cnt)
      let l:file.is_marked = !l:file.is_marked
    endif

    let l:cnt += 1
  endwhile
  
  call vimfiler#redraw_screen()
endfunction"}}}
function! s:toggle_mark_lines(start, end)"{{{
  let l:cnt = a:start
  while l:cnt <= a:end
    let l:line = getline(l:cnt)
    if vimfiler#check_filename_line(l:line)
      " Toggle mark.
      let l:file = vimfiler#get_file(l:cnt)
      let l:file.is_marked = !l:file.is_marked
    endif

    let l:cnt += 1
  endwhile
  
  call vimfiler#redraw_screen()
endfunction"}}}
function! s:clear_mark_all_lines()"{{{
  let l:max = line('$')
  let l:cnt = 1
  while l:cnt <= l:max
    let l:line = getline(l:cnt)
    if vimfiler#check_filename_line(l:line)
      " Clear mark.

      let l:file = vimfiler#get_file(l:cnt)
      let l:file.is_marked = 0
    endif

    let l:cnt += 1
  endwhile
  call vimfiler#redraw_screen()
endfunction"}}}
function! s:execute()"{{{
  let l:line = getline('.')
  let l:filename = vimfiler#get_filename(line('.'))
  if l:filename != '..' && !vimfiler#check_filename_line()
    let l:cursor_line = matchstr(l:line[: col('.') - 1], '^Current directory: \zs.*')
    if l:cursor_line != ''
      " Change current directory.
      let l:cursor_next = matchstr(l:line[col('.') :], '.\{-}\ze[/\\]')

      call vimfiler#internal_commands#cd(l:cursor_line . l:cursor_next)
    endif

    return
  endif

  let l:filename = vimfiler#resolve(l:filename)

  if isdirectory(l:filename)
    " Change directory.
    call vimfiler#internal_commands#cd(l:filename)
  else
    " User execute file.
    let l:ext = fnamemodify(l:filename, ':e')
    if has_key(g:vimfiler_execute_file_list, l:ext)
      let l:command = g:vimfiler_execute_file_list[l:ext]
      if l:command == 'vim'
        " Edit with vim.
        call vimfiler#internal_commands#edit(vimfiler#get_filename(line('.')), 0)
      else
        call vimfiler#internal_commands#gexe(printf('%s ''%s''',
              \ g:vimfiler_execute_file_list[l:ext], l:filename))
      endif
    endif
  endif
endfunction"}}}
function! s:execute_file()"{{{
  let l:filename = vimfiler#get_filename(line('.'))
  if l:filename != '..' && !vimfiler#check_filename_line()
    return
  endif

  " Execute cursor file.
  call vimfiler#internal_commands#open(l:filename)
endfunction"}}}
function! s:move_to_other_window()"{{{
  if winnr('$') == 1
    " Create another vimfiler.
    call vimfiler#create_filer(b:vimfiler.current_dir,
          \ b:vimfiler.is_simple ? ['split', 'simple'] : ['split'])
    let s:last_vimfiler_bufnr = bufnr('%')
    wincmd w
    call vimfiler#force_redraw_screen()
  endif

  wincmd w
endfunction"}}}

function! s:move_to_drive()"{{{
  let l:drives = vimfiler#get_drives()

  if empty(l:drives)
    " No drives.
    return
  endif

  for [l:key, l:drive] in items(l:drives)
    echo printf('[%s] %s', l:key, l:drive)
  endfor

  let l:key = vimfiler#resolve(expand(input('Please input drive alphabet or other directory: ', '', 'dir')))
  
  if l:key == ''
    return
  elseif has_key(l:drives, tolower(l:key))
    call vimfiler#internal_commands#cd(l:drives[tolower(l:key)])
  elseif isdirectory(l:key)
    call vimfiler#internal_commands#cd(l:key)
  else
    redraw
    echo 'Invalid directory name.'
    return
  endif
endfunction"}}}
function! s:jump_to_history_directory()"{{{
  let l:cnt = 0
  for l:directory in b:vimfiler.changed_dir
    echo printf('%s[%s] %s',
          \ (l:cnt == b:vimfiler.current_changed_dir_index ? '*' : ' '),
          \ l:cnt, l:directory)
    let l:cnt += 1
  endfor

  let l:key = input('Please input history number: ')
  
  if l:key == '' || l:key !~ '^\d\+$'
    return
  endif
  
  let l:num = str2nr(l:key)
  if l:num < len(b:vimfiler.changed_dir)
    call vimfiler#internal_commands#cd(b:vimfiler.changed_dir[l:num])
  else
    redraw
    echo 'Invalid history number.'
  endif
endfunction"}}}
function! s:jump_to_directory()"{{{
  let l:dir = vimfiler#resolve(expand(input('Jump to: ', '', 'dir')))
  if l:dir == ''
    redraw
    echo 'Canceled.'
    return
  elseif isdirectory(l:dir)
    call vimfiler#internal_commands#cd(l:dir)
  else
    redraw
    echo 'Invalid directory name.'
    return
  endif
endfunction"}}}

function! s:toggle_visible_dot_files()"{{{
  let b:vimfiler.is_visible_dot_files = !b:vimfiler.is_visible_dot_files
  call vimfiler#force_redraw_screen()
endfunction"}}}
function! s:popup_shell()"{{{
  if exists(':VimShellPop')
    let l:files = join(vimfiler#get_escaped_marked_files())
    call s:clear_mark_all_lines()
    
    VimShellPop `=b:vimfiler.current_dir`
    
    if l:files != ''
      call setline(line('.'), getline('.') . ' ' . l:files)
      normal! l
    endif
  else
    " Run shell.
    shell
  endif
endfunction"}}}
function! s:edit_file(is_split)"{{{
  if !vimfiler#check_filename_line()
    return
  endif

  call vimfiler#internal_commands#edit(vimfiler#get_filename(line('.')), a:is_split)
endfunction"}}}
function! s:edit_binary_file(is_split)"{{{
  if !vimfiler#check_filename_line()
    return
  endif

  if !exists(':Vinarise')
    call vimfiler#print_error('vinarise is not found. Please install it.')
    return
  endif

  if a:is_split
    call vimfiler#internal_commands#split()
  endif

  Vinarise `=vimfiler#get_filename(line('.'))`
endfunction"}}}
function! s:preview_file()"{{{
  if !vimfiler#check_filename_line()
    return
  endif

  call vimfiler#internal_commands#pedit(vimfiler#get_filename(line('.')))
endfunction"}}}
function! s:execute_external_command()"{{{
  let l:command = input('Input external command: ', '', 'shellcmd')
  if l:command == ''
    redraw
    echo 'Canceled.'
    return
  endif

  call vimfiler#internal_commands#gexe(l:command)
endfunction"}}}
function! s:execute_shell_command()"{{{
  let l:command = input('Input shell command: ', '', 'shellcmd')
  if l:command == ''
    redraw
    echo 'Canceled.'
    return
  endif

  let l:command = substitute(l:command, 
        \'\s\+\zs\*\ze\%([;|[:space:]]\|$\)', join(vimfiler#get_escaped_marked_files()), 'g')
  echo vimfiler#system(l:command)
endfunction"}}}
function! s:exit()"{{{
  let l:vimfiler_buf = bufnr('%')
  " Switch buffer.
  if winnr('$') != 1
    close
  else
    call s:custom_alternate_buffer()
  endif
  execute 'bdelete!' l:vimfiler_buf
endfunction"}}}
function! s:sync_with_current_vimfiler()"{{{
  " Search vimfiler window.
  if !vimfiler#exists_another_vimfiler()
    call vimfiler#create_filer(b:vimfiler.current_dir, 
          \b:vimfiler.is_simple ? ['split', 'simple'] : ['split'])
    let s:last_vimfiler_bufnr = bufnr('%')
  else
    " Change another vimfiler directory.
    let l:current_dir = b:vimfiler.current_dir
    execute vimfiler#winnr_another_vimfiler() . 'wincmd w'
    call vimfiler#internal_commands#cd(l:current_dir)
  endif

  wincmd p
endfunction"}}}
function! s:sync_with_another_vimfiler()"{{{
  " Search vimfiler window.
  if  !vimfiler#exists_another_vimfiler()
    call vimfiler#create_filer(b:vimfiler.current_dir, 
          \b:vimfiler.is_simple ? ['split', 'simple'] : ['split'])
    let s:last_vimfiler_bufnr = bufnr('%')
    wincmd p
  else
    " Change current vimfiler directory.
    call vimfiler#internal_commands#cd(vimfiler#get_another_vimfiler().current_dir)
  endif
endfunction"}}}

" File operations.
function! s:move()"{{{
  let l:marked_files = vimfiler#get_marked_filenames()
  if empty(l:marked_files)
    " Mark current line.
    call s:toggle_mark_current_line()
    return
  endif

  if !vimfiler#exists_another_vimfiler()
    if g:vimfiler_enable_clipboard
      " Copy to clipboard.
      let b:vimfiler.clipboard = {
            \ 'command' : 'move', 'files' : l:marked_files
            \}
      call s:clear_mark_all_lines()
      echo 'Saved to clipboard.'
      return
    else
      " Input destination directory.
      let l:dest_dir = vimfiler#input_directory('Input destination directory: ')
    endif
  else
    " Get destination directory.
    let l:dest_dir = vimfiler#get_another_vimfiler().current_dir
  endif

  if l:dest_dir ==# b:vimfiler.current_dir
    " Rename.
    call s:rename()
    return
  endif

  let l:yes = vimfiler#input_yesno('Really move marked files?')

  if l:yes
    " Execute move.
    call vimfiler#internal_commands#mv(l:dest_dir . '/', l:marked_files)
    call s:clear_mark_all_lines()
    call vimfiler#force_redraw_all_vimfiler()
  endif
endfunction"}}}
function! s:copy()"{{{
  let l:marked_files = vimfiler#get_marked_filenames()
  if empty(l:marked_files)
    " Mark current line.
    call s:toggle_mark_current_line()
    return
  endif

  if !vimfiler#exists_another_vimfiler()
    if g:vimfiler_enable_clipboard
      " Copy to clipboard.
      let b:vimfiler.clipboard = {
            \ 'command' : 'copy', 'files' : l:marked_files
            \}
      call s:clear_mark_all_lines()
      echo 'Saved to clipboard.'
      return
    else
      " Input destination directory.
      let l:dest_dir = vimfiler#input_directory('Input destination directory: ')
    endif
  else
    " Get destination directory.
    let l:dest_dir = vimfiler#get_another_vimfiler().current_dir
  endif

  if l:dest_dir ==# b:vimfiler.current_dir
        \ || l:dest_dir == '.'
    if len(l:marked_files) > 1
      echo 'Same directory.'
      return
    endif

    " Rename copy.
    let l:oldfilename = l:marked_files[0]
    let l:filename = input(printf('New filename: %s -> ', l:oldfilename), l:oldfilename, 'file')
    if l:filename == '' || l:filename ==# l:oldfilename
      redraw
      echo 'Canceled.'

      return
    endif

    let l:dest_dir = l:filename
  else
    let l:dest_dir .= '/'
  endif

  " Execute copy.
  call vimfiler#internal_commands#cp(l:dest_dir, l:marked_files)
  call s:clear_mark_all_lines()
  call vimfiler#force_redraw_all_vimfiler()
endfunction"}}}
function! s:delete()"{{{
  let l:marked_files = vimfiler#get_marked_filenames()
  if empty(l:marked_files)
    " Mark current line.
    call s:toggle_mark_current_line()
    return
  endif
  let l:yes = vimfiler#input_yesno('Really move marked files to trashbox?')

  if l:yes
    " Execute delete.
    if !isdirectory(g:vimfiler_trashbox_directory)
      call mkdir(g:vimfiler_trashbox_directory, 'p')
    endif

    let l:trashdir = s:encode_trash_path(b:vimfiler.current_dir[: -2])
    if !isdirectory(l:trashdir)
      call mkdir(l:trashdir, 'p')
    endif

    if l:trashdir !~ '[/\\]$'
      let l:trashdir .= '/'
    endif

    call vimfiler#internal_commands#mv(l:trashdir, l:marked_files)
    call vimfiler#force_redraw_all_vimfiler()
  else
    redraw
    echo 'Canceled.'
  endif
endfunction"}}}
function! s:force_delete()"{{{
  let l:marked_files = vimfiler#get_marked_filenames()
  if empty(l:marked_files)
    " Mark current line.
    call s:toggle_mark_current_line()
    return
  endif
  let l:yes = vimfiler#input_yesno('Really force delete marked files?')

  if l:yes
    " Execute force delete.
    call vimfiler#internal_commands#rm(l:marked_files)
    call vimfiler#force_redraw_all_vimfiler()
  else
    redraw
    echo 'Canceled.'
  endif
endfunction"}}}
function! s:rename()"{{{
  if !vimfiler#check_filename_line()
    return
  endif

  let l:marked_files = vimfiler#get_marked_filenames()
  if !empty(l:marked_files)
    " Extended rename.
    call vimfiler#exrename#create_buffer(vimfiler#get_marked_files())
    return
  endif

  let l:oldfilename = vimfiler#get_filename(line('.'))
  
  let l:filename = input(printf('New filename: %s -> ', l:oldfilename), l:oldfilename, 'file')
  if l:filename == '' || l:filename ==# l:oldfilename
    redraw
    echo 'Canceled.'
  else
    call rename(l:oldfilename, l:filename)
    call vimfiler#force_redraw_all_vimfiler()
  endif
endfunction"}}}
function! s:make_directory()"{{{
  let l:current_dir = getcwd()
  let l:dirname = input('New directory name: ', '', 'dir')

  if l:dirname == ''
    redraw
    echo 'Canceled.'
  elseif isdirectory(l:dirname) || filereadable(l:dirname)
    redraw
    echo 'File exists.'
  else
    if &termencoding != '' && &termencoding != &encoding
      let l:dirname = iconv(l:dirname, &encoding, &termencoding)
    endif

    call mkdir(l:dirname, 'p')
    call vimfiler#force_redraw_all_vimfiler()
    call vimfiler#internal_commands#cd(l:dirname)
  endif
endfunction"}}}
function! s:new_file()"{{{
  let l:filenames = input('New files name(comma separated multiple files): ', '', 'file')
  if l:filenames == ''
    redraw
    echo 'Canceled.'
    return
  endif

  for l:filename in split(l:filenames, ',')
    if filereadable(l:filename)
      redraw
      echo l:filename . ' is exists.'
    else
      call writefile([], l:filename)

      call vimfiler#force_redraw_all_vimfiler()
      call vimfiler#internal_commands#edit(l:filename, 0)

      doautocmd BufNewFile
    endif
  endfor
endfunction"}}}
function! s:paste_from_clipboard()"{{{
  if empty(b:vimfiler.clipboard)
    echo 'Clipboard is empty.'
    return
  endif

  if b:vimfiler.clipboard.command ==# 'copy'
    call vimfiler#internal_commands#cp(b:vimfiler.current_dir, b:vimfiler.clipboard.files)
    call vimfiler#force_redraw_all_vimfiler()
  elseif b:vimfiler.clipboard.command ==# 'move'
    call vimfiler#internal_commands#mv(b:vimfiler.current_dir, b:vimfiler.clipboard.files)
    call vimfiler#force_redraw_all_vimfiler()
    
    let b:vimfiler.clipboard = {}
  else
    call vimfiler#print_error('Invalid command.')
  endif
endfunction"}}}

function! s:set_current_mask()"{{{
  let l:mask = input('Please input new mask pattern: ', '')

  let b:vimfiler.current_mask = l:mask
  call vimfiler#force_redraw_screen()
endfunction"}}}
function! s:restore_from_trashbox()"{{{
  if !vimfiler#head_match(b:vimfiler.current_dir, g:vimfiler_trashbox_directory . '/')
    echo 'This command is valid in trashbox directory.'
    return
  elseif s:decode_trash_path(b:vimfiler.current_dir) == ''
    echo 'Invalid restore path.'
    return
  endif

  let l:marked_files = vimfiler#get_marked_filenames()
  if empty(l:marked_files)
    " Mark current line.
    call s:toggle_mark_current_line()
    return
  endif
  let l:yes = vimfiler#input_yesno('Restore marked files in trashbox?')

  if l:yes
    " Execute restore.
    let l:restoredir = fnamemodify(s:decode_trash_path(l:marked_files[0]), ':h')
    if l:restoredir !~ '[/\\]$'
      let l:restoredir .= '/'
    endif

    call vimfiler#internal_commands#mv(l:restoredir, l:marked_files)
    call vimfiler#force_redraw_all_vimfiler()
  else
    redraw
    echo 'Canceled.'
  endif
endfunction"}}}
function! s:grep()"{{{
  try
    let l:unite_source = unite#get_sources('grep')
  catch
    call vimfiler#print_error('unite.vim or unite-grep is not installed. grep command is disabled.')
    return
  endtry
  if empty(l:unite_source)
    call vimfiler#print_error('unite.vim or unite-grep is not installed. grep command is disabled.')
    return
  endif

  let l:marked_files = vimfiler#get_marked_files()
  if empty(l:marked_files)
    redraw
    echo 'Canceled.'
    return
  endif
  let l:target = join(map(l:marked_files, 'v:val.name'))

  call unite#start([['grep', l:target, '-R']])
endfunction"}}}
function! s:select_sort_type()"{{{
  for l:type in ['n[one]', 's[ize]', 'e[xtension]', 'f[ilename]', 't[ime]', 'm[anual]']
    echo l:type
  endfor
  let l:sort_type = input(printf('Select sort type(Upper case is descending order) %s -> ', b:vimfiler.sort_type), '')

  if l:sort_type == ''
    redraw
    echo 'Canceled.'
  elseif l:sort_type =~? 
        \'^\%(n\%[one]\|s\%[ize]\|e\%[xtension]\|f\%[ilename]\|t\%[ime]\|m\%[anual]\)$'
    let b:vimfiler.sort_type = l:sort_type
    call vimfiler#force_redraw_screen()
  else
    call vimfiler#print_error('Invalid sort type.')
  endif
endfunction"}}}
function! s:switch_vim_buffer_mode()"{{{
  redir => l:nmaps
  silent nmap <buffer>
  redir END

  let b:vimfiler.mapdict = {}
  for l:map in split(l:nmaps, '\n')
    let l:lhs = split(l:map)[1]
    let l:rhs = join(split(l:map)[2: ])[1:]
    if l:rhs =~ '^<Plug>(vimfiler_'
      let b:vimfiler.mapdict[l:lhs] = l:rhs
      execute 'nunmap <buffer>' l:lhs
    endif
  endfor

  nmap <buffer> <ESC> <Plug>(vimfiler_restore_vimfiler_mode)

  echo 'Switched vim buffer mode'
endfunction"}}}
function! s:restore_vimfiler_mode()"{{{
  for [l:lhs, l:rhs] in items(b:vimfiler.mapdict)
    execute 'nmap <buffer>' l:lhs l:rhs
  endfor

  echo 'Switched vimfiler mode'
endfunction"}}}
function! s:cd()"{{{
  call vimfiler#cd(b:vimfiler.current_dir)
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
  nnoremap <buffer><silent> <Plug>(vimfiler_copy_file)  :<C-u>call <SID>mappings_caller('copy')<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_move_file)  :<C-u>call <SID>mappings_caller('move')<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_delete_file)  :<C-u>call <SID>mappings_caller('delete')<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_force_delete_file)  :<C-u>call <SID>mappings_caller('force_delete')<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_rename_file)  :<C-u>call <SID>mappings_caller('rename')<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_make_directory)  :<C-u>call <SID>mappings_caller('make_directory')<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_new_file)  :<C-u>call <SID>mappings_caller('new_file')<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_restore_from_trashbox)  :<C-u>call <SID>restore_from_trashbox()<CR>
endfunction"}}}
function! s:unmapping_file_operations()"{{{
  nnoremap <buffer><silent> <Plug>(vimfiler_copy_file)  :<C-u>call <SID>disable_operation()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_move_file)  :<C-u>call <SID>disable_operation()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_delete_file)  :<C-u>call <SID>disable_operation()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_force_delete_file)  :<C-u>call <SID>disable_operation()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_rename_file)  :<C-u>call <SID>disable_operation()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_make_directory)  :<C-u>call <SID>disable_operation()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_new_file)  :<C-u>call <SID>disable_operation()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_restore_from_trashbox)  :<C-u>call <SID>disable_operation()<CR>
endfunction"}}}
function! s:disable_operation()"{{{
  call vimfiler#print_error('In safe mode, this operation is disabled.')
endfunction"}}}

function! s:history_forward()"{{{
  if len(b:vimfiler.changed_dir) < 2
    return
  endif
  if b:vimfiler.current_changed_dir_index ==# -1
    return
  endif

  let b:vimfiler.current_changed_dir_index += 1
  let l:dir = b:vimfiler.changed_dir[b:vimfiler.current_changed_dir_index]

  " Reset b:vimfiler.current_changed_dir_index
  if len(b:vimfiler.changed_dir) - 2 ==# b:vimfiler.current_changed_dir_index
    let b:vimfiler.current_changed_dir_index = -1
  endif

  call vimfiler#internal_commands#cd(l:dir, 0)
endfunction"}}}
function! s:history_back()"{{{
  if len(b:vimfiler.changed_dir) < 2
    return
  endif
  if b:vimfiler.current_changed_dir_index ==# 0
    return
  endif

  if b:vimfiler.current_changed_dir_index ==# -1
    " Last item must be b:vimfiler.current_dir
    let b:vimfiler.current_changed_dir_index = len(b:vimfiler.changed_dir) - 2
  else
    let b:vimfiler.current_changed_dir_index -= 1
  endif

  let l:dir = b:vimfiler.changed_dir[b:vimfiler.current_changed_dir_index]
  call vimfiler#internal_commands#cd(l:dir, 0)
endfunction"}}}

function! s:custom_alternate_buffer()"{{{
  if bufnr('%') != bufnr('#') && buflisted(bufnr('#'))
    buffer #
  else
    let l:cnt = 0
    let l:pos = 1
    let l:current = 0
    while l:pos <= bufnr('$')
      if buflisted(l:pos)
        if l:pos == bufnr('%')
          let l:current = l:cnt
        endif

        let l:cnt += 1
      endif

      let l:pos += 1
    endwhile

    if l:current > l:cnt / 2
      bprevious
    else
      bnext
    endif
  endif

  call vimfiler#force_redraw_all_vimfiler()
endfunction"}}}

function! s:encode_trash_path(path)"{{{
  return printf('%s/%s/%s', g:vimfiler_trashbox_directory,
        \ substitute(strftime('%Y%m%d/%X'), ':', '_', 'g'),
        \ substitute(substitute(a:path, ':[/\\]\?', '++', 'g'), '[/\\]', '=', 'g'))
endfunction"}}}
function! s:decode_trash_path(path)"{{{
  let l:path = matchstr(a:path[len(g:vimfiler_trashbox_directory)+1 :], '^[^/]\+/[^/]\+/\zs.*')
  return substitute(substitute(l:path, '++/\?', ':/', 'g'), '/\?+/\?', '/', 'g')
endfunction"}}}
" vim: foldmethod=marker

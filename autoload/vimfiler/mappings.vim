"=============================================================================
" FILE: mappings.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 06 Apr 2013.
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

scriptencoding utf-8

let s:Cache = vital#of('vimfiler').import('System.Cache')

function! s:SID_PREFIX()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_\zeSID_PREFIX$')
endfunction

function! vimfiler#mappings#define_default_mappings(context) "{{{
  " Plugin keymappings "{{{
  nnoremap <buffer><expr> <Plug>(vimfiler_loop_cursor_down)
        \ (line('.') == line('$'))?
        \  vimfiler#get_file_offset().'Gzb' : 'j'
  nnoremap <buffer><expr> <Plug>(vimfiler_loop_cursor_up)
        \ (line('.') == 1)? 'G' : 'k'
  nnoremap <buffer><silent> <Plug>(vimfiler_redraw_screen)
        \ :<C-u>call vimfiler#force_redraw_screen(1)<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_toggle_mark_current_line)
        \ :<C-u>call <SID>toggle_mark_current_line('j')<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_toggle_mark_current_line_up)
        \ :<C-u>call <SID>toggle_mark_current_line('k')<CR>
  vnoremap <buffer><silent> <Plug>(vimfiler_toggle_mark_selected_lines)
        \ :<C-u>call <SID>toggle_mark_lines(getpos("'<")[1], getpos("'>")[1])<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_toggle_mark_all_lines)
        \ :<C-u>call <SID>toggle_mark_all_lines()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_mark_similar_lines)
        \ :<C-u>call <SID>mark_similar_lines()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_clear_mark_all_lines)
        \ :<C-u>call <SID>clear_mark_all_lines()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_mark_current_line)
        \ :<C-u>call <SID>mark_current_line()<CR>
  nmap <buffer><silent><expr> <Plug>(vimfiler_execute)
        \ vimfiler#mappings#smart_cursor_map(
        \  "\<Plug>(vimfiler_cd_file)",
        \  "\<Plug>(vimfiler_execute_vimfiler_associated)")
  nmap <buffer> <Plug>(vimfiler_execute_file)
        \ <Plug>(vimfiler_execute_system_associated)
  nnoremap <buffer><silent> <Plug>(vimfiler_execute_system_associated)
        \ :<C-u>call <SID>execute_system_associated()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_execute_vimfiler_associated)
        \ :<C-u>call <SID>execute_vimfiler_associated()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_switch_to_parent_directory)
        \ :<C-u>call vimfiler#mappings#cd('..')<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_switch_to_home_directory)
        \ :<C-u>call vimfiler#mappings#cd('file:~')<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_switch_to_root_directory)
        \ :<C-u>call vimfiler#mappings#cd('file:/')<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_switch_to_drive)
        \ :<C-u>call <SID>switch_to_drive()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_switch_to_history_directory)
        \ :<C-u>call <SID>switch_to_history_directory()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_toggle_visible_dot_files)
        \ :<C-u>call <SID>toggle_visible_dot_files()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_popup_shell)
        \ :<C-u>call <SID>popup_shell()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_edit_file)
        \ :<C-u>call <SID>edit()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_split_edit_file)
        \ :<C-u>call <SID>split_edit_file()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_edit_binary_file)
        \ :<C-u>call <SID>edit_binary_file()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_execute_external_filer)
        \ :<C-u>call <SID>execute_external_filer()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_execute_shell_command)
        \ :<C-u>call <SID>execute_shell_command()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_hide)
        \ :<C-u>call <SID>hide()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_exit)
        \ :<C-u>call <SID>exit()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_close)
        \ :<C-u>call <SID>close()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_help)
        \ :<C-u>call <SID>help()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_preview_file)
        \ :<C-u>call vimfiler#mappings#do_action(g:vimfiler_preview_action)<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_sync_with_current_vimfiler)
        \ :<C-u>call <SID>sync_with_current_vimfiler()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_sync_with_another_vimfiler)
        \ :<C-u>call <SID>sync_with_another_vimfiler()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_open_file_in_another_vimfiler)
        \ :<C-u>call <SID>open_file_in_another_vimfiler()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_print_filename)
        \ :<C-u>call <SID>print_filename()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_toggle_maximize_window)
        \ :<C-u>call <SID>toggle_maximize_window()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_yank_full_path)
        \ :<C-u>call <SID>yank_full_path()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_set_current_mask)
        \ :<C-u>call <SID>set_current_mask()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_grep)
        \ :<C-u>call <SID>grep()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_find)
        \ :<C-u>call <SID>find()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_select_sort_type)
        \ :<C-u>call <SID>select_sort_type()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_switch_to_other_window)
        \ :<C-u>call <SID>switch_to_other_window()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_switch_to_another_vimfiler)
        \ :<C-u>call <SID>switch_to_another_vimfiler()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_switch_vim_buffer_mode)
        \ :<C-u>call <SID>switch_vim_buffer_mode()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_restore_vimfiler_mode)
        \ :<C-u>call <SID>restore_vimfiler_mode()<CR>
  nmap <buffer> <Plug>(vimfiler_cd)
        \ <Plug>(vimfiler_cd_vim_current_dir)
  nnoremap <buffer><silent> <Plug>(vimfiler_cd_vim_current_dir)
        \ :<C-u>call <SID>change_vim_current_dir()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_cd_file)
        \ :<C-u>call <SID>cd_file_directory()<CR>
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
  if a:context.explorer
    nnoremap <buffer><silent><expr> <Plug>(vimfiler_smart_h)
          \ line('.') == 1 ? 'h' :
          \  ":\<C-u>call \<SID>unexpand_tree()\<CR>"
    nnoremap <buffer><silent><expr> <Plug>(vimfiler_smart_l)
          \ line('.') == 1 ? 'l' :
          \  ":\<C-u>call \<SID>expand_tree()\<CR>"
  else
    nnoremap <buffer><silent><expr> <Plug>(vimfiler_smart_h)
          \ line('.') == 1 ? 'h' :
          \  ":\<C-u>call vimfiler#mappings#cd('..')\<CR>"
    nnoremap <buffer><silent><expr> <Plug>(vimfiler_smart_l)
          \ line('.') == 1 ? 'l' :
          \  ":\<C-u>call \<SID>execute()\<CR>"
  endif
  nnoremap <buffer><silent><expr> <Plug>(vimfiler_cursor_top)
        \ vimfiler#get_file_offset().'Gzb'
  nnoremap <buffer><silent> <Plug>(vimfiler_expand_tree)
        \ :<C-u>call <SID>toggle_tree()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_expand_tree_recursive)
        \ :<C-u>call <SID>toggle_tree_recursive()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_cd_input_directory)
        \ :<C-u>call <SID>cd_input_directory()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_double_click)
        \ :<C-u>call <SID>on_double_click()<CR>
  nmap <buffer><silent> <Plug>(vimfiler_quick_look)
        \ :<C-u>call <SID>quick_look()<CR>

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

  if a:context.split && a:context.no_quit
    " Change default mapping.
    nmap <buffer> <TAB> <Plug>(vimfiler_switch_to_other_window)
  else
    nmap <buffer> <TAB> <Plug>(vimfiler_switch_to_another_vimfiler)
  endif
  nmap <buffer> j <Plug>(vimfiler_loop_cursor_down)
  nmap <buffer> k <Plug>(vimfiler_loop_cursor_up)

  " Toggle mark.
  nmap <buffer> <C-l> <Plug>(vimfiler_redraw_screen)
  nmap <buffer> <Space> <Plug>(vimfiler_toggle_mark_current_line)
  nmap <buffer> <S-Space> <Plug>(vimfiler_toggle_mark_current_line_up)
  vmap <buffer> <Space> <Plug>(vimfiler_toggle_mark_selected_lines)

  " Toggle marks in all lines.
  nmap <buffer> * <Plug>(vimfiler_toggle_mark_all_lines)
  nmap <buffer> & <Plug>(vimfiler_mark_similar_lines)
  " Clear marks in all lines.
  nmap <buffer> U <Plug>(vimfiler_clear_mark_all_lines)

  " Copy files.
  nmap <buffer> c <Plug>(vimfiler_copy_file)
  nmap <buffer> Cc <Plug>(vimfiler_clipboard_copy_file)

  " Move files.
  nmap <buffer> m <Plug>(vimfiler_move_file)
  nmap <buffer> Cm <Plug>(vimfiler_clipboard_move_file)

  " Delete files.
  nmap <buffer> d <Plug>(vimfiler_delete_file)

  " Rename.
  nmap <buffer> r <Plug>(vimfiler_rename_file)

  " Make directory.
  nmap <buffer> K <Plug>(vimfiler_make_directory)

  " New file.
  nmap <buffer> N <Plug>(vimfiler_new_file)

  " Paste.
  nmap <buffer> Cp <Plug>(vimfiler_clipboard_paste)

  " Execute or change directory.
  nmap <buffer> <Enter> <Plug>(vimfiler_execute)
  nmap <buffer> l <Plug>(vimfiler_smart_l)

  nmap <buffer> x
        \ <Plug>(vimfiler_execute_system_associated)

  " Move to directory.
  nmap <buffer> h <Plug>(vimfiler_smart_h)
  nmap <buffer> L <Plug>(vimfiler_switch_to_drive)
  nmap <buffer> ~ <Plug>(vimfiler_switch_to_home_directory)
  nmap <buffer> \ <Plug>(vimfiler_switch_to_root_directory)
  nmap <buffer> <C-j> <Plug>(vimfiler_switch_to_history_directory)
  nmap <buffer> <BS> <Plug>(vimfiler_switch_to_parent_directory)

  nmap <buffer> gv <Plug>(vimfiler_execute_new_gvim)
  nmap <buffer> . <Plug>(vimfiler_toggle_visible_dot_files)
  nmap <buffer> H <Plug>(vimfiler_popup_shell)

  " Edit file.
  nmap <buffer> e <Plug>(vimfiler_edit_file)
  nmap <buffer> E <Plug>(vimfiler_split_edit_file)
  nmap <buffer> B <Plug>(vimfiler_edit_binary_file)

  " Choose action.
  nmap <buffer> a <Plug>(vimfiler_choose_action)

  " Hide vimfiler.
  nmap <buffer> q <Plug>(vimfiler_hide)
  " Exit vimfiler.
  nmap <buffer> Q <Plug>(vimfiler_exit)
  " Close vimfiler.
  nmap <buffer> - <Plug>(vimfiler_close)

  nmap <buffer> ge <Plug>(vimfiler_execute_external_filer)
  nmap <buffer> <RightMouse> <Plug>(vimfiler_execute_external_filer)

  nmap <buffer> ! <Plug>(vimfiler_execute_shell_command)
  nmap <buffer> ? <Plug>(vimfiler_help)
  nmap <buffer> v <Plug>(vimfiler_preview_file)
  nmap <buffer> o <Plug>(vimfiler_sync_with_current_vimfiler)
  nmap <buffer> O <Plug>(vimfiler_open_file_in_another_vimfiler)
  nmap <buffer> <C-g> <Plug>(vimfiler_print_filename)
  nmap <buffer> g<C-g> <Plug>(vimfiler_toggle_maximize_window)
  nmap <buffer> yy <Plug>(vimfiler_yank_full_path)
  nmap <buffer> M <Plug>(vimfiler_set_current_mask)
  nmap <buffer> gr <Plug>(vimfiler_grep)
  nmap <buffer> gf <Plug>(vimfiler_find)
  nmap <buffer> S <Plug>(vimfiler_select_sort_type)
  nmap <buffer> <C-v> <Plug>(vimfiler_switch_vim_buffer_mode)
  nmap <buffer> gc <Plug>(vimfiler_cd_vim_current_dir)
  nmap <buffer> gs <Plug>(vimfiler_toggle_safe_mode)
  nmap <buffer> gS <Plug>(vimfiler_toggle_simple_mode)
  nmap <buffer> gg <Plug>(vimfiler_cursor_top)
  nmap <buffer> t <Plug>(vimfiler_expand_tree)
  nmap <buffer> T <Plug>(vimfiler_expand_tree_recursive)
  nmap <buffer> I <Plug>(vimfiler_cd_input_directory)
  nmap <buffer> <2-LeftMouse>
        \ <Plug>(vimfiler_double_click)

  " pushd/popd
  nmap <buffer> Y <Plug>(vimfiler_pushd)
  nmap <buffer> P <Plug>(vimfiler_popd)
endfunction"}}}

function! vimfiler#mappings#smart_cursor_map(directory_map, file_map) "{{{
  let filename = vimfiler#get_filename()
  let file = vimfiler#get_file()
  return  filename == '..' || empty(file)
        \ || file.vimfiler__is_directory ?
        \ a:directory_map : a:file_map
endfunction"}}}

function! vimfiler#mappings#do_action(action, ...) "{{{
  let cursor_linenr = get(a:000, 0, line('.'))
  let vimfiler = vimfiler#get_current_vimfiler()
  let marked_files = vimfiler#get_marked_files()
  if empty(marked_files)
    let file = vimfiler#get_file(cursor_linenr)
    if empty(file)
      return
    endif

    let marked_files = [ file ]
  endif

  call s:clear_mark_all_lines()

  return vimfiler#mappings#do_files_action(
        \ a:action, marked_files, cursor_linenr)
endfunction"}}}

function! vimfiler#mappings#do_files_action(action, files, ...) "{{{
  let cursor_linenr = get(a:000, 0, line('.'))
  let vimfiler = vimfiler#get_current_vimfiler()

  " Execute action.
  let current_dir = vimfiler.current_dir
  call unite#mappings#do_action(a:action, a:files, {
        \ 'vimfiler__current_directory' : current_dir,
        \ })
endfunction"}}}

function! vimfiler#mappings#do_current_dir_action(action, ...) "{{{
  let context = get(a:000, 0, {})
  let vimfiler = vimfiler#get_current_vimfiler()

  return vimfiler#mappings#do_dir_action(a:action, vimfiler.current_dir, context)
endfunction"}}}

function! vimfiler#mappings#do_dir_action(action, directory, ...) "{{{
  let context = get(a:000, 0, {})
  let vimfiler = vimfiler#get_current_vimfiler()
  let context.vimfiler__current_directory = a:directory

  let files = vimfiler#get_marked_files()
  if empty(files)
    let context.vimfiler__is_dummy = 1

    let files = unite#get_vimfiler_candidates(
          \ [[vimfiler.source, a:directory]], context)
    if empty(files)
      return
    endif
  else
    let context.vimfiler__is_dummy = 0
  endif

  " Execute action.
  call unite#mappings#do_action(a:action, files, context)
endfunction"}}}

function! vimfiler#mappings#cd(dir, ...) "{{{
  if &filetype !=# 'vimfiler'
    return
  endif
  let save_history = get(a:000, 0, 1)

  let dir = vimfiler#util#substitute_path_separator(a:dir)
  if b:vimfiler.source !=# 'file' &&
        \ dir !~ ':' && dir =~ '^/\|^\a:'
    " Use file source.
    let dir = 'file:' . dir
  endif

  if dir =~ ':'
    " Parse path.
    let ret = vimfiler#parse_path(dir)
    let b:vimfiler.source = ret[0]
    let dir = join(ret[1:], ':')
  endif

  let previous_current_dir = b:vimfiler.current_dir
  if previous_current_dir =~ '/$'
    let previous_current_dir = previous_current_dir[: -2]
  endif
  let current_dir = b:vimfiler.current_dir

  if dir == '..'
    if vimfiler#util#is_windows() && current_dir =~ '^//'
      " For UNC path.
      let current_dir = substitute(current_dir,
            \ '^//[^/]*/[^/]*', '', '')
    endif

    let chars = split(current_dir, '\zs')
    if count(chars, '/') <= 1
      if count(chars, ':') < 1
            \ || b:vimfiler.source ==# 'file'
        " Ignore.
        return
      endif
      let dir = substitute(
            \ b:vimfiler.current_dir, ':[^:]*$', '', '')
    else
      let dir = fnamemodify(substitute(
            \ b:vimfiler.current_dir, '[/\\]$', '', ''), ':h')
    endif

    if dir =~ '//$'
      return
    endif

  elseif dir == '/'
    " Root.

    if vimfiler#util#is_windows() && current_dir =~ '^//'
      " For UNC path.
      let dir = matchstr(current_dir, '^//[^/]*/[^/]*')
    else
      let dir = vimfiler#util#is_windows() ?
            \ matchstr(fnamemodify(current_dir, ':p'),
            \         '^\a\+:[/\\]') : dir
    endif
  elseif dir == '~'
    " Home.
    let dir = expand('~')
  elseif dir =~ ':'
        \ || (vimfiler#util#is_windows() && dir =~ '^//')
        \ || (!vimfiler#util#is_windows() && dir =~ '^/')
    " Network drive or absolute path.
  else
    " Relative path.
    let dir = simplify(current_dir . dir)
  endif
  let fullpath = vimfiler#util#substitute_path_separator(dir)

  if vimfiler#util#is_windows()
    let fullpath = vimfiler#util#resolve(fullpath)
  endif

  if fullpath !~ '/$'
    let fullpath .= '/'
  endif

  " Save current pos.
  let save_pos = getpos('.')
  let b:vimfiler.directory_cursor_pos[b:vimfiler.current_dir] =
        \ deepcopy(save_pos)
  let prev_dir = b:vimfiler.current_dir
  let b:vimfiler.current_dir = fullpath

  if vimfiler#get_context().auto_cd
    call s:change_vim_current_dir()
  endif

  " Save changed directories.
  if save_history
    let histories = vimfiler#get_histories()
    call add(histories, [bufname('%'), prev_dir])

    let max_save = g:vimfiler_max_directories_history > 0 ?
          \ g:vimfiler_max_directories_history : 10
    if len(histories) >= max_save
      " Get last max_save num elements.
      let histories = histories[-max_save :]
    endif

    call vimfiler#set_histories(histories)
  endif

  " Check sort type.
  let cache_dir = g:vimfiler_data_directory . '/' . 'sort'
  let path = b:vimfiler.source.'/'.b:vimfiler.current_dir
  if s:Cache.filereadable(cache_dir, path)
    let b:vimfiler.local_sort_type =
          \ s:Cache.readfile(cache_dir, path)[0]
  else
    let b:vimfiler.local_sort_type = b:vimfiler.global_sort_type
  endif

  let b:vimfiler.original_files = []
  let b:vimfiler.current_files = []

  " Redraw.
  call vimfiler#force_redraw_screen()

  call s:restore_cursor(a:dir, fullpath, save_pos,
        \ previous_current_dir)
endfunction"}}}
function! s:restore_cursor(dir, fullpath, save_pos, previous_current_dir) "{{{
  " Restore cursor pos.
  if a:dir ==# '..'
    " Search previous current directory.

    let num = 0
    let max = len(b:vimfiler.current_files)
    while num < max
      let path = b:vimfiler.current_files[num].action__path
      if path ==#
            \ b:vimfiler.source.':'.a:previous_current_dir
            \ || path ==# a:previous_current_dir
        call cursor(vimfiler#get_line_number(num), 1)
        break
      endif

      let num += 1
    endwhile
  elseif has_key(b:vimfiler.directory_cursor_pos, a:fullpath)
    call setpos('.', b:vimfiler.directory_cursor_pos[a:fullpath])
  else
    call cursor(vimfiler#get_file_offset(), 0)
  endif

  call vimfiler#helper#_set_cursor()
endfunction"}}}

function! vimfiler#mappings#search_cursor(path) "{{{
  let max = line('$')
  let cnt = 1
  while cnt <= max
    let file = vimfiler#get_file(cnt)
    if !empty(file) && file.action__path ==# a:path
      " Move cursor.
      call cursor(cnt, 0)
    endif

    let cnt += 1
  endwhile
endfunction"}}}

function! s:search_new_file(old_files) "{{{
  let cnt = 0
  for file in
        \ vimfiler#get_current_vimfiler().current_files
    if file.action__path !=#
          \ get(get(a:old_files, cnt, {}), 'action__path', '')
      " Move cursor.
      call cursor(vimfiler#get_line_number(cnt), 0)
      break
    endif

    let cnt += 1
  endfor
endfunction"}}}

function! vimfiler#mappings#close(buffer_name) "{{{
  let quit_winnr = vimfiler#util#get_vimfiler_winnr(a:buffer_name)
  if quit_winnr > 0
    " Hide unite buffer.
    silent execute quit_winnr 'wincmd w'

    if winnr('$') != 1
      close
    else
      call vimfiler#util#alternate_buffer()
    endif
  endif

  return quit_winnr > 0
endfunction"}}}

function! s:switch() "{{{
  let context = vimfiler#get_context()
  if context.no_quit
    let vimfiler = vimfiler#get_current_vimfiler()

    call vimfiler#set_current_vimfiler(vimfiler)

    let winnr = bufwinnr(context.vimfiler__prev_bufnr)
    if winnr < 0
      let winnr = context.vimfiler__prev_winnr
    endif
    if context.split
      wincmd w
    elseif winnr == winnr() || winnr < 0
      vnew
    else
      execute winnr 'wincmd w'
    endif
  elseif context.quit
    call s:exit()
  endif
endfunction"}}}
function! s:toggle_mark_current_line(...) "{{{
  let file = vimfiler#get_file()
  if empty(file)
    " Don't toggle.
    return
  endif

  let file.vimfiler__is_marked = !file.vimfiler__is_marked
  let file.vimfiler__marked_time = localtime()

  setlocal modifiable
  call setline('.', vimfiler#view#_get_print_lines([file]))
  setlocal nomodifiable

  let map = get(a:000, 0, '')
  if map == ''
    return
  endif

  if map ==# 'j'
    if line('.') != line('$')
      normal! j
    endif
  elseif map ==# 'k'
    if line('.') > 2
      normal! k
    endif
  else
    execute 'normal!' map
  endif
endfunction"}}}
function! s:mark_current_line() "{{{
  let file = vimfiler#get_file()
  if empty(file)
    " Don't toggle.
    return
  endif

  let file.vimfiler__is_marked = 1
  let file.vimfiler__marked_time = localtime()

  setlocal modifiable
  call setline('.', vimfiler#view#_get_print_lines([file]))
  setlocal nomodifiable
endfunction"}}}
function! s:toggle_mark_all_lines() "{{{
  for file in vimfiler#get_current_vimfiler().current_files
    let file.vimfiler__is_marked = !file.vimfiler__is_marked
    let file.vimfiler__marked_time = localtime()
  endfor

  call vimfiler#redraw_screen()
endfunction"}}}
function! s:mark_similar_lines() "{{{
  let file = vimfiler#get_file()
  if empty(file)
    " Don't toggle.
    return
  endif

  " Get pattern.
  let idents = []
  let pos = 0
  let ident = matchstr(file.vimfiler__filename, '\I\+')
  while ident != ''
    call add(idents, ident)
    let pos = matchend(file.vimfiler__filename, '\I\+', pos)

    let ident = matchstr(file.vimfiler__filename, '\I\+', pos)
  endwhile

  let pattern = join(idents, '.\+')
  for file in filter(copy(
        \ vimfiler#get_current_vimfiler().current_files),
        \ 'v:val.vimfiler__filename =~# pattern')
    let file.vimfiler__is_marked = 1
    let file.vimfiler__marked_time = localtime()
  endfor

  call vimfiler#redraw_screen()
endfunction"}}}
function! s:toggle_mark_lines(start, end) "{{{
  let cnt = a:start
  while cnt <= a:end
    let file = vimfiler#get_file(cnt)
    if !empty(file)
      " Toggle mark.
      let file.vimfiler__is_marked = !file.vimfiler__is_marked
      let file.vimfiler__marked_time = localtime()
    endif

    let cnt += 1
  endwhile

  call vimfiler#redraw_screen()
endfunction"}}}
function! s:clear_mark_all_lines() "{{{
  for file in vimfiler#get_current_vimfiler().current_files
    let file.vimfiler__is_marked = 0
  endfor

  call vimfiler#redraw_screen()
endfunction"}}}
function! s:execute() "{{{
  let filename = vimfiler#get_filename()
  let file = vimfiler#get_file()
  return  filename == '..' || empty(file)
        \ || file.vimfiler__is_directory ?
        \ s:cd_file_directory() :
        \ s:execute_vimfiler_associated()
endfunction"}}}
function! s:execute_vimfiler_associated() "{{{
  call unite#start(['vimfiler/execute'],
        \ { 'immediately' : 1, 'buffer_name' : 'vimfiler/execute', 'script' : 1 })
endfunction"}}}
function! s:execute_system_associated() "{{{
  let marked_files = vimfiler#get_marked_files()
  if empty(marked_files)
    let file = vimfiler#get_file()
    if empty(file)
      call s:execute_external_filer()
      return
    endif

    let marked_files = [file]
  endif

  call s:clear_mark_all_lines()

  " Execute marked files.
  call unite#mappings#do_action('vimfiler__execute', marked_files, {
        \ 'vimfiler__current_directory' : b:vimfiler.current_dir,
        \ })
endfunction"}}}
function! s:switch_to_other_window() "{{{
  if winnr('$') != 1 || !exists('b:vimfiler')
    wincmd w
    return
  endif

  call s:switch_to_another_vimfiler()
endfunction"}}}
function! s:switch_to_another_vimfiler() "{{{
  if vimfiler#exists_another_vimfiler()
    call vimfiler#mappings#switch_another_vimfiler()
  else
    " Create another vimfiler.
    call vimfiler#mappings#create_another_vimfiler()
    call vimfiler#redraw_all_vimfiler()
  endif
endfunction"}}}
function! s:print_filename() "{{{
  let filename = vimfiler#get_filename()
  if filename != '..' && empty(vimfiler#get_file())
    let filename = matchstr(getline('.'),
          \ ' Current directory: \zs.*\ze[/\\]')
  endif

  echo filename
endfunction"}}}
function! s:yank_full_path() "{{{
  let filename = join(vimfiler#get_marked_filenames(), "\n")

  if filename == ''
    " Use cursor filename.
    let filename = vimfiler#get_filename()
    if filename == '..' || empty(vimfiler#get_file())
      let filename = vimfiler#get_current_vimfiler().current_dir
    else
      let filename = vimfiler#get_file().action__path
    endif
  endif

  let @" = filename
  if has('clipboard') || has('xterm_clipboard')
    let @+ = filename
  endif

  echo 'Yanked: '.filename
endfunction"}}}
function! s:toggle_tree() "{{{
  let file = vimfiler#get_file()
  if empty(file) || vimfiler#get_filename() == '..'
    return
  endif

  if !file.vimfiler__is_directory
    " Search parent directory.
    for cnt in reverse(range(1, line('.')-1))
      let nest_level = get(vimfiler#get_file(cnt),
            \ 'vimfiler__nest_level', -1)
      if nest_level >= 0 && nest_level < file.vimfiler__nest_level
        call cursor(cnt, 0)
        call s:toggle_tree()
        break
      endif
    endfor
    return
  endif

  if file.vimfiler__is_opened
    call s:unexpand_tree()
  else
    call s:expand_tree()
  endif

  call vimfiler#view#_check_redraw()
endfunction"}}}
function! s:expand_tree() "{{{
  let file = vimfiler#get_file()
  if empty(file) || vimfiler#get_filename() == '..'
    return
  endif

  if !file.vimfiler__is_directory
    " Search parent directory.
    for cnt in reverse(range(1, line('.')-1))
      let nest_level = get(vimfiler#get_file(cnt),
            \ 'vimfiler__nest_level', -1)
      if nest_level >= 0 && nest_level < file.vimfiler__nest_level
        call cursor(cnt, 0)
        call s:expand_tree()
        break
      endif
    endfor
    return
  endif

  if file.vimfiler__is_opened
    return
  endif

  setlocal modifiable

  let file.vimfiler__is_opened = 1
  call setline('.', vimfiler#view#_get_print_lines([file]))

  " Expand tree.
  let nestlevel = file.vimfiler__nest_level + 1

  let original_files =
        \ vimfiler#get_directory_files(file.action__path)
  for file in original_files
    " Initialize.
    let file.vimfiler__nest_level = nestlevel
  endfor

  let files =
        \ unite#filters#matcher_vimfiler_mask#define().filter(
        \ copy(original_files),
        \ { 'input' : b:vimfiler.current_mask })
  if !b:vimfiler.is_visible_dot_files
    call filter(files, 'v:val.vimfiler__filename !~ "^\\."')
  endif

  let index = vimfiler#get_file_index(line('.'))
  let index_orig =
        \ vimfiler#get_original_file_index(line('.'))

  let b:vimfiler.current_files =
        \ b:vimfiler.current_files[: index]
        \  + files + b:vimfiler.current_files[index+1 :]
  let b:vimfiler.original_files =
        \ b:vimfiler.original_files[: index_orig]
        \  + original_files
        \  + b:vimfiler.original_files[index_orig+1 :]

  call append('.', vimfiler#view#_get_print_lines(files))

  setlocal nomodifiable
endfunction"}}}
function! s:toggle_tree_recursive() "{{{
  let file = vimfiler#get_file()
  if empty(file) || vimfiler#get_filename() == '..'
    return
  endif

  if !file.vimfiler__is_directory
    " Search parent directory.
    for cnt in reverse(range(1, line('.')-1))
      let nest_level = get(vimfiler#get_file(cnt),
            \ 'vimfiler__nest_level', -1)
      if nest_level == 0
        call cursor(cnt, 0)
        call s:toggle_tree_recursive()
        break
      endif
    endfor
    return
  endif

  if file.vimfiler__is_opened
    call s:unexpand_tree()
    call vimfiler#view#_check_redraw()
    return
  endif

  setlocal modifiable

  let file.vimfiler__is_opened = 1
  call setline('.', vimfiler#view#_get_print_lines([file]))

  " Expand tree.
  let nestlevel = file.vimfiler__nest_level + 1

  let original_files = vimfiler#mappings#expand_tree_rec(file)

  let files =
        \ unite#filters#matcher_vimfiler_mask#define().filter(
        \ copy(original_files),
        \ { 'input' : b:vimfiler.current_mask })

  let index = vimfiler#get_file_index(line('.'))
  let index_orig = vimfiler#get_original_file_index(line('.'))

  let b:vimfiler.current_files = b:vimfiler.current_files[: index]
        \ + files + b:vimfiler.current_files[index+1 :]
  let b:vimfiler.original_files = b:vimfiler.original_files[: index_orig]
        \ + original_files + b:vimfiler.original_files[index_orig+1 :]

  call append('.', vimfiler#view#_get_print_lines(files))

  setlocal nomodifiable

  call vimfiler#view#_check_redraw()
endfunction"}}}
function! vimfiler#mappings#expand_tree_rec(file, ...) "{{{
  if get(a:file, 'vimfiler__ftype', '') ==# 'link'
    " Ignore symbolic link.
    return []
  endif

  let old_original_files = get(a:000, 0, {})
  let a:file.vimfiler__is_opened = 1

  " Expand tree.
  let nestlevel = a:file.vimfiler__nest_level + 1

  let _ = []
  for file in vimfiler#get_directory_files(a:file.action__path)
    " Initialize.
    let file.vimfiler__nest_level = nestlevel

    if !b:vimfiler.is_visible_dot_files
          \ && file.vimfiler__filename =~ '^\.'
      continue
    endif

    call add(_, file)

    if file.vimfiler__is_directory
          \ && (empty(old_original_files) ||
          \ has_key(old_original_files, file.action__path))
      let _ += vimfiler#mappings#expand_tree_rec(file, old_original_files)
    endif
  endfor

  return _
endfunction"}}}
function! s:unexpand_tree() "{{{
  let file = vimfiler#get_file()
  if empty(file) || vimfiler#get_filename() == '..'
    return
  endif

  if !file.vimfiler__is_directory || !file.vimfiler__is_opened
    " Search parent directory.
    for cnt in reverse(range(1, line('.')-1))
      let nest_level = get(vimfiler#get_file(cnt),
            \ 'vimfiler__nest_level', -1)
      if nest_level >= 0 && nest_level < file.vimfiler__nest_level
        call cursor(cnt, 0)
        call s:unexpand_tree()
        break
      endif
    endfor

    return
  endif

  if !file.vimfiler__is_opened
    return
  endif

  setlocal modifiable

  let file.vimfiler__is_opened = 0
  call setline('.', vimfiler#view#_get_print_lines([file]))

  let index = vimfiler#get_file_index(line('.'))
  let index_orig = vimfiler#get_original_file_index(line('.'))

  " Unexpand tree.
  let nestlevel = file.vimfiler__nest_level

  " Search children.
  let end = index
  for file in b:vimfiler.current_files[index+1 :]
    if file.vimfiler__nest_level <= nestlevel
      break
    endif

    let end += 1
  endfor

  let end_orig = index_orig
  for file in b:vimfiler.original_files[index_orig+1 :]
    if file.vimfiler__nest_level <= nestlevel
      break
    endif

    let end_orig += 1
  endfor

  if end - index > 0
    " Delete children.
    let b:vimfiler.current_files = b:vimfiler.current_files[: index]
          \ + b:vimfiler.current_files[end+1 :]
    let b:vimfiler.original_files = b:vimfiler.original_files[: index_orig]
          \ + b:vimfiler.current_files[end_orig+1 :]
    let pos = getpos('.')
    silent execute (line('.')+1).','.(vimfiler#get_line_number(end)).'delete _'
    call setpos('.', pos)
  endif

  setlocal nomodifiable
endfunction"}}}

function! s:switch_to_drive() "{{{
  call unite#start(['vimfiler/drive'],
        \ { 'buffer_name' : 'vimfiler/drive', 'script' : 1 })
endfunction"}}}
function! s:switch_to_history_directory() "{{{
  call unite#start(['vimfiler/history'],
        \ { 'buffer_name' : 'vimfiler/history', 'script' : 1 })
endfunction"}}}
function! s:pushd() "{{{
  call unite#sources#vimfiler_popd#pushd()
endfunction"}}}
function! s:popd() "{{{
  call unite#start(['vimfiler/popd'],
        \ { 'buffer_name' : 'vimfiler/popd', 'script' : 1 })
endfunction"}}}

function! s:toggle_visible_dot_files() "{{{
  let b:vimfiler.is_visible_dot_files = !b:vimfiler.is_visible_dot_files
  call vimfiler#redraw_screen()
endfunction"}}}
function! s:popup_shell() "{{{
  let files = vimfiler#get_escaped_marked_files()
  call s:clear_mark_all_lines()

  call vimfiler#mappings#do_current_dir_action('vimfiler__shell', {
        \ 'vimfiler__files' : files,
        \})
endfunction"}}}
function! s:edit() "{{{
  let current_linenr = line('.')
  call s:switch()

  call vimfiler#mappings#do_action(g:vimfiler_edit_action, current_linenr)
endfunction"}}}
function! s:edit_binary_file() "{{{
  let file = vimfiler#get_file()
  if empty(file)
    return
  endif

  if !exists(':Vinarise')
    call vimfiler#print_error('vinarise is not found. Please install it.')
    return
  endif

  call s:switch()

  execute 'Vinarise' escape(vimfiler#get_filename(), ' ')
endfunction"}}}
function! s:execute_shell_command() "{{{
  let marked_files = vimfiler#get_marked_files()
  if !empty(marked_files)
    echo 'Marked files:'
    echohl Type | echo join(vimfiler#get_marked_filenames(), "\n") | echohl NONE
  endif

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
  elseif !empty(marked_files)
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

  call s:clear_mark_all_lines()

  call vimfiler#mappings#do_current_dir_action(
        \ 'vimfiler__shellcmd', {
        \ 'vimfiler__command' : command,
        \})
endfunction"}}}
function! s:hide() "{{{
  let bufnr = bufnr('%')

  let context = vimfiler#get_context()

  if vimfiler#winnr_another_vimfiler() > 0
    " Hide another vimfiler.
    let bufnr = b:vimfiler.another_vimfiler_bufnr
    close
    execute bufwinnr(bufnr).'wincmd w'
    call s:hide()
  elseif winnr('$') != 1 && (context.split || context.toggle)
    close
  else
    call vimfiler#util#alternate_buffer()
  endif
endfunction"}}}
function! s:exit() "{{{
  if vimfiler#winnr_another_vimfiler() > 0
    let bufnr = b:vimfiler.another_vimfiler_bufnr
    " Exit another vimfiler.
    call vimfiler#util#delete_buffer()
    execute bufwinnr(bufnr).'wincmd w'
    call vimfiler#util#delete_buffer()
  else
    call vimfiler#util#delete_buffer()
  endif
endfunction"}}}
function! s:close() "{{{
  let bufnr = bufnr('%')

  let context = vimfiler#get_context()

  if vimfiler#winnr_another_vimfiler() > 0
    " Close current vimfiler.
    let bufnr = b:vimfiler.another_vimfiler_bufnr
    close
    execute bufwinnr(bufnr).'wincmd w'
    call vimfiler#redraw_screen()
  elseif winnr('$') != 1 && (context.split || context.toggle)
    close
  else
    call vimfiler#util#alternate_buffer()
  endif
endfunction"}}}
function! vimfiler#mappings#create_another_vimfiler() "{{{
  let current_vimfiler = vimfiler#get_current_vimfiler()
  let current_bufnr = bufnr('%')
  let line = line('.')

  " Create another vimfiler.
  let context = deepcopy(vimfiler#get_context())
  if context.split || context.explorer
    " Note: Horizontal automatically.
    let context.horizontal = 1
  endif
  if context.reverse
    " Reverse split direction.
    let context.horizontal = !context.horizontal
  endif
  let context.split = 1
  let context.double = 0
  let context.create = 1
  let context.direction = 'belowright'

  call vimfiler#start(
        \ current_vimfiler.source.':'.
        \ current_vimfiler.current_dir, context)
  call cursor(line, 0)
  call vimfiler#helper#_set_cursor()

  let b:vimfiler.another_vimfiler_bufnr = current_bufnr
  call vimfiler#set_current_vimfiler(b:vimfiler)
  let current_vimfiler.another_vimfiler_bufnr = bufnr('%')
endfunction"}}}
function! vimfiler#mappings#switch_another_vimfiler(...) "{{{
  let directory = get(a:000, 0, '')
  if vimfiler#winnr_another_vimfiler() > 0
    " Switch to another vimfiler window.
    execute vimfiler#winnr_another_vimfiler().'wincmd w'
    if directory != ''
      " Change current directory.
      call vimfiler#mappings#cd(directory)
    endif
  else
    " Open another vimfiler buffer.
    let current_vimfiler = vimfiler#get_current_vimfiler()

    let context = deepcopy(vimfiler#get_context())
    let context.split = 1
    let context.double = 0
    let context.direction = 'belowright'
    if context.reverse
      " Reverse split direction.
      let context.horizontal = !context.horizontal
    endif

    call vimfiler#init#_switch_vimfiler(
          \ current_vimfiler.another_vimfiler_bufnr,
          \ context, directory)
  endif
endfunction"}}}
function! s:sync_with_current_vimfiler() "{{{
  " Search vimfiler window.
  let line = line('.')
  if vimfiler#exists_another_vimfiler()
    " Change another vimfiler directory.
    call vimfiler#mappings#switch_another_vimfiler(
          \ b:vimfiler.source . ':' . b:vimfiler.current_dir)
    call cursor(line, 0)
  else
    call vimfiler#mappings#create_another_vimfiler()
  endif

  call vimfiler#helper#_set_cursor()

  wincmd p
  call cursor(line, 0)
  call vimfiler#redraw_screen()
endfunction"}}}
function! s:sync_with_another_vimfiler() "{{{
  " Search vimfiler window.
  if vimfiler#exists_another_vimfiler()
    " Change current vimfiler directory.

    let another = vimfiler#get_another_vimfiler()
    call vimfiler#mappings#switch_another_vimfiler()
    let line = line('.')
    wincmd p
    call vimfiler#mappings#cd(
          \ another.source . ':' . another.current_dir)
  else
    call vimfiler#mappings#create_another_vimfiler()
    let line = line('.')
    wincmd p
    call vimfiler#redraw_screen()
  endif

  call cursor(line, 0)
endfunction"}}}
function! s:open_file_in_another_vimfiler() "{{{
  " Search vimfiler window.
  let files = vimfiler#get_marked_files()
  if empty(files)
    let files = [vimfiler#get_file()]
  endif

  call s:clear_mark_all_lines()

  call s:switch_to_other_window()

  if len(files) > 1 || !files[0].vimfiler__is_directory
    call vimfiler#mappings#do_files_action(g:vimfiler_edit_action, files)
  else
    call vimfiler#mappings#cd(files[0].action__path)
  endif

  call s:switch_to_other_window()
endfunction"}}}
function! s:choose_action() "{{{
  let marked_files = vimfiler#get_marked_files()
  if empty(marked_files)
    if empty(vimfiler#get_file())
      return
    endif

    let marked_files = [ vimfiler#get_file() ]
  endif

  call unite#mappings#_choose_action(marked_files, {
        \ 'vimfiler__current_directory' :
        \   vimfiler#get_current_vimfiler().current_dir,
        \ })
endfunction"}}}
function! s:split_edit_file() "{{{
  let context = vimfiler#get_context()
  let winwidth = (winnr('$') != 1) ?
        \ &columns - (winwidth(0)+1)/2*2 :
        \ (context.winwidth == 0) ?
        \ &columns / 2 :
        \ &columns - context.winwidth
  call vimfiler#mappings#do_action(g:vimfiler_split_action)

  " Resize.
  execute 'vertical resize'
        \ (winnr('$') == 1 ? winwidth : winwidth/(winnr('$') - 1))
endfunction"}}}

" File operations.
function! s:copy() "{{{
  let marked_files = vimfiler#get_marked_files()
  if empty(marked_files)
    " Mark current line.
    call s:toggle_mark_current_line()
    return
  endif

  " Get destination directory.
  let dest_dir = ''
  if vimfiler#winnr_another_vimfiler() > 0
    let another = vimfiler#get_another_vimfiler()
    if another.source !=# 'file'
      let dest_dir = another.source . ':'
    endif

    let dest_dir .= another.current_dir
  endif

  let old_files = copy(vimfiler#get_current_vimfiler().current_files)

  " Execute copy.
  call unite#mappings#do_action('vimfiler__copy', marked_files, {
        \ 'action__directory' : dest_dir,
        \ 'vimfiler__current_directory' :
        \       s:get_action_current_dir(marked_files),
        \ })
  call s:clear_mark_all_lines()

  call s:search_new_file(old_files)
endfunction"}}}
function! s:move() "{{{
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

  redraw

  " Get destination directory.
  let dest_dir = ''
  if vimfiler#winnr_another_vimfiler() > 0
    let another = vimfiler#get_another_vimfiler()
    if another.source !=# 'file'
      let dest_dir = another.source . ':'
    endif

    let dest_dir .= another.current_dir
  endif

  " Execute move.
  call unite#mappings#do_action('vimfiler__move', marked_files, {
        \ 'action__directory' : dest_dir,
        \ 'vimfiler__current_directory' :
        \       s:get_action_current_dir(marked_files),
        \ })
  call s:clear_mark_all_lines()
endfunction"}}}
function! s:delete() "{{{
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
        \ 'vimfiler__current_directory' :
        \       s:get_action_current_dir(marked_files),
        \ })
  call s:clear_mark_all_lines()
endfunction"}}}
function! s:rename() "{{{
  let marked_files = vimfiler#get_marked_filenames()
  if !empty(marked_files)
    " Extended rename.
    call vimfiler#exrename#create_buffer(vimfiler#get_marked_files())
    return
  endif

  let file = vimfiler#get_file()
  if empty(file)
    return
  endif

  call unite#mappings#do_action('vimfiler__rename', [file], {
        \ 'vimfiler__current_directory' :
        \       s:get_action_current_dir([file]),
        \ })
endfunction"}}}
function! s:make_directory() "{{{
  let directory = vimfiler#get_file_directory()
  let old_files =
        \ copy(vimfiler#get_current_vimfiler().current_files)

  call vimfiler#mappings#do_dir_action('vimfiler__mkdir', directory)

  call s:search_new_file(old_files)
endfunction"}}}
function! s:new_file() "{{{
  let directory = vimfiler#get_file_directory()

  call s:switch()

  call vimfiler#mappings#do_dir_action('vimfiler__newfile', directory)
endfunction"}}}
function! s:clipboard_copy() "{{{
  let marked_files = vimfiler#get_marked_files()
  if empty(marked_files)
    " Mark current line.
    call s:toggle_mark_current_line()
    return
  endif

  let b:vimfiler.clipboard = {
        \ 'operation' : 'copy',
        \ 'files' : marked_files,
        \ }
  call s:clear_mark_all_lines()

  echo 'Copied files to vimfiler clipboard.'
endfunction"}}}
function! s:clipboard_move() "{{{
  let marked_files = vimfiler#get_marked_files()
  if empty(marked_files)
    " Mark current line.
    call s:toggle_mark_current_line()
    return
  endif

  let b:vimfiler.clipboard = {
        \ 'operation' : 'move',
        \ 'files' : marked_files,
        \ }
  call s:clear_mark_all_lines()

  echo 'Moved files to vimfiler clipboard.'
endfunction"}}}
function! s:clipboard_paste() "{{{
  if empty(b:vimfiler.clipboard)
    call vimfiler#print_error('Clipboard is empty.')
    return
  endif

  " Get destination directory.
  let dest_dir = vimfiler#get_file_directory()

  " Execute file operation.
  call unite#mappings#do_action(
        \ 'vimfiler__' . b:vimfiler.clipboard.operation,
        \ b:vimfiler.clipboard.files, {
        \ 'action__directory' : dest_dir,
        \ 'vimfiler__current_directory' : dest_dir,
        \ })

  let b:vimfiler.clipboard = {}
endfunction"}}}

function! s:set_current_mask() "{{{
  call unite#start(['vimfiler/mask'],
        \ { 'start_insert' : 1, 'buffer_name' : 'vimfiler/mask', 'script' : 1 })
endfunction"}}}
function! s:select_sort_type() "{{{
  call unite#start(['vimfiler/sort'],
        \ { 'buffer_name' : 'vimfiler/sort', 'script' : 1 })
endfunction"}}}
function! s:switch_vim_buffer_mode() "{{{
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
function! s:restore_vimfiler_mode() "{{{
  for [lhs, rhs] in items(b:vimfiler.mapdict)
    execute 'nmap <buffer>' lhs rhs
  endfor

  echo 'Switched vimfiler mode'
endfunction"}}}
function! s:help() "{{{
  call unite#start(['mapping'],
        \ { 'buffer_name' : 'vimfiler/mapping', 'script' : 1 })
endfunction"}}}
function! s:execute_external_filer() "{{{
  call vimfiler#mappings#do_current_dir_action('vimfiler__execute')
endfunction"}}}
function! s:change_vim_current_dir() "{{{
  if b:vimfiler.source !=# 'file'
    call vimfiler#print_error('Invalid operation in not file source.')
    return
  endif

  " Initialize load.
  call unite#kinds#openable#define()

  execute g:unite_kind_openable_lcd_command '`=b:vimfiler.current_dir`'
endfunction"}}}
function! s:grep() "{{{
  if !vimfiler#util#has_vimproc()
    call vimfiler#print_error('Sorry, vimproc is not installed. '.
          \ 'This mapping use vimproc.')
    return
  endif

  call unite#sources#grep#define()

  call s:switch()

  if empty(vimfiler#get_marked_files())
    call vimfiler#mappings#do_current_dir_action('grep')
  else
    call vimfiler#mappings#do_action('grep')
  endif
endfunction"}}}
function! s:find() "{{{
  if !vimfiler#util#has_vimproc()
    call vimfiler#print_error('Sorry, vimproc is not installed. '.
          \ 'This mapping use vimproc.')
    return
  endif

  call unite#sources#find#define()

  call s:switch()

  call vimfiler#mappings#do_current_dir_action('find')
endfunction"}}}
function! s:cd_file_directory() "{{{
  let filename = vimfiler#get_filename()

  if filename == '..'
  elseif empty(vimfiler#get_file())
    let line = getline('.')
    let cursor_line = matchstr(line[: col('.') - 1], '\[in\]: \zs.*')
    if cursor_line == ''
      return
    endif

    " Change current directory.
    let cursor_next = matchstr(line[col('.') :], '.\{-}\ze[/\\]')

    let filename = cursor_line . cursor_next
  else
    let filename = vimfiler#util#resolve(
          \ vimfiler#get_file().action__path)
  endif

  " Change directory.
  call vimfiler#mappings#cd(filename)
endfunction"}}}
function! s:cd_input_directory() "{{{
  let vimfiler = vimfiler#get_current_vimfiler()
  let current_dir = vimfiler.current_dir
  let dir = input('[in]: ',
        \ vimfiler.source . ':'. current_dir,
        \ 'customlist,vimfiler#complete_path')

  if dir == ''
    echo 'Canceled.'
    return
  endif

  " Change directory.
  call vimfiler#mappings#cd(dir)
endfunction"}}}
function! s:on_double_click() "{{{
  let file = vimfiler#get_file()
  if empty(file)
        \ || !file.vimfiler__is_directory
    if vimfiler#get_filename() ==# '..'
      call vimfiler#mappings#cd('..')
    else
      call s:execute_system_associated()
    endif
  else
    call s:toggle_tree()
  endif
endfunction"}}}
function! s:quick_look() "{{{
  if !vimfiler#util#has_vimproc()
    call vimfiler#print_error(
          \ 'vimproc is needed for this feature.')
    return
  endif

  if !executable(g:vimfiler_quick_look_command)
    call vimfiler#print_error(
          \ 'g:vimfiler_quick_look_command "'.
          \ g:vimfiler_quick_look_command.'"is not executable.')
    return
  endif

  let file = vimfiler#get_file()
  if empty(file)
    return
  endif

  let command = vimproc#util#iconv(
        \ g:vimfiler_quick_look_command . ' ' .
        \   file.action__path, &encoding, 'char')

  call vimproc#system_gui(command)
endfunction"}}}

" For safe mode.
function! s:toggle_safe_mode() "{{{
  let b:vimfiler.is_safe_mode = !b:vimfiler.is_safe_mode
  echo 'Safe mode is ' . (b:vimfiler.is_safe_mode ? 'enabled' : 'disabled')
  call vimfiler#redraw_prompt()

  if b:vimfiler.is_safe_mode
    call s:unmapping_file_operations()
  else
    call s:mapping_file_operations()
  endif
endfunction"}}}
function! s:mapping_file_operations() "{{{
  nnoremap <buffer><silent> <Plug>(vimfiler_copy_file)
        \ :<C-u>call <SID>copy()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_move_file)
        \ :<C-u>call <SID>move()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_delete_file)
        \ :<C-u>call <SID>delete()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_rename_file)
        \ :<C-u>call <SID>rename()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_make_directory)
        \ :<C-u>call <SID>make_directory()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_new_file)
        \ :<C-u>call <SID>new_file()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_clipboard_copy_file)
        \ :<C-u>call <SID>clipboard_copy()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_clipboard_move_file)
        \ :<C-u>call <SID>clipboard_move()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_clipboard_paste)
        \ :<C-u>call <SID>clipboard_paste()<CR>
endfunction"}}}
function! s:unmapping_file_operations() "{{{
  nnoremap <buffer><silent> <Plug>(vimfiler_copy_file)
        \ :<C-u>call <SID>disable_operation()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_move_file)
        \ :<C-u>call <SID>disable_operation()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_delete_file)
        \ :<C-u>call <SID>disable_operation()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_rename_file)
        \ :<C-u>call <SID>disable_operation()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_make_directory)
        \ :<C-u>call <SID>disable_operation()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_new_file)
        \ :<C-u>call <SID>disable_operation()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_clipboard_copy_file)
        \ :<C-u>call <SID>disable_operation()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_clipboard_move_file)
        \ :<C-u>call <SID>disable_operation()<CR>
  nnoremap <buffer><silent> <Plug>(vimfiler_clipboard_paste)
        \ :<C-u>call <SID>disable_operation()<CR>
endfunction"}}}
function! s:disable_operation() "{{{
  call vimfiler#print_error('In safe mode, this operation is disabled.')
endfunction"}}}

function! s:toggle_simple_mode() "{{{
  let b:vimfiler.context.simple = !b:vimfiler.context.simple
  call vimfiler#redraw_screen()
  echo 'Simple mode is ' .
        \ (b:vimfiler.context.simple ? 'enabled' : 'disabled')
endfunction"}}}
function! s:toggle_maximize_window() "{{{
  let std_width = vimfiler#get_context().winwidth
  if std_width == 0
    let std_width = (&columns+1)/2
  endif

  let winwidth = (winwidth(0)+1)/2*2
  if winwidth == std_width
    execute 'vertical resize' &columns
  else
    execute 'vertical resize' std_width
  endif

  call vimfiler#redraw_screen()

  setlocal winfixwidth
endfunction"}}}

function! s:get_action_current_dir(files) "{{{
  let current_dir = b:vimfiler.current_dir
  if len(a:files) == 1
    let current_dir = a:files[0].action__directory
    if a:files[0].vimfiler__is_directory
      let current_dir = vimfiler#util#substitute_path_separator(
            \   fnamemodify(current_dir, ':h'))
    endif
  endif

  return current_dir
endfunction"}}}

" vim: foldmethod=marker

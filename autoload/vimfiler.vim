"=============================================================================
" FILE: vimfiler.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 23 May 2010
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
" Version: 1.50, for Vim 7.0
"=============================================================================

" Check vimproc.
let s:is_vimproc = exists('*vimproc#system')

let s:last_vimfiler_bufnr = bufnr('%')

" Global options definition."{{{
if !exists('g:vimfiler_execute_file_list')
  let g:vimfiler_execute_file_list = {}
endif
"}}}

" Plugin keymappings"{{{
nnoremap <silent> <Plug>(vimfiler_loop_cursor_down)  :<C-u>call vimfiler#mappings#loop_cursor_down()<CR>
nnoremap <silent> <Plug>(vimfiler_loop_cursor_up)  :<C-u>call vimfiler#mappings#loop_cursor_up()<CR>
nnoremap <silent> <Plug>(vimfiler_redraw_screen)  :<C-u>call vimfiler#force_redraw_screen()<CR>
nnoremap <silent> <Plug>(vimfiler_toggle_mark_current_line)  :<C-u>call vimfiler#mappings#toggle_mark_current_line()<CR>j
nnoremap <silent> <Plug>(vimfiler_toggle_mark_all_lines)  :<C-u>call vimfiler#mappings#toggle_mark_all_lines()<CR>
nnoremap <silent> <Plug>(vimfiler_execute)  :<C-u>call vimfiler#mappings#execute()<CR>
nnoremap <silent> <Plug>(vimfiler_execute_file)  :<C-u>call vimfiler#mappings#execute_file()<CR>
nnoremap <silent> <Plug>(vimfiler_move_to_up_directory)  :<C-u>call vimfiler#internal_commands#cd('..')<CR>
nnoremap <silent> <Plug>(vimfiler_move_to_home_directory)  :<C-u>call vimfiler#internal_commands#cd('~')<CR>
nnoremap <silent> <Plug>(vimfiler_move_to_root_directory)  :<C-u>call vimfiler#internal_commands#cd('/')<CR>
nnoremap <silent> <Plug>(vimfiler_move_to_trashbox_directory)  :<C-u>call vimfiler#internal_commands#cd(g:vimfiler_trashbox_directory)<CR>
nnoremap <silent> <Plug>(vimfiler_move_to_drive)  :<C-u>call vimfiler#mappings#move_to_drive()<CR>
nnoremap <silent> <Plug>(vimfiler_jump_to_directory)  :<C-u>call vimfiler#mappings#jump_to_directory()<CR>
nnoremap <silent> <Plug>(vimfiler_execute_new_gvim)  :<C-u>call vimfiler#internal_commands#gexe('gvim')<CR>
nnoremap <silent> <Plug>(vimfiler_toggle_visible_dot_files)  :<C-u>call vimfiler#mappings#toggle_visible_dot_files()<CR>
nnoremap <silent> <Plug>(vimfiler_popup_shell)  :<C-u>call vimfiler#mappings#popup_shell()<CR>
nnoremap <silent> <Plug>(vimfiler_edit_file)  :<C-u>call vimfiler#mappings#edit_file()<CR>
nnoremap <silent> <Plug>(vimfiler_execute_external_filer)  :<C-u>call vimfiler#internal_commands#open(b:vimfiler.current_dir)<CR>
nnoremap <silent> <Plug>(vimfiler_execute_external_command)  :<C-u>call vimfiler#mappings#execute_external_command()<CR>
nnoremap <silent> <Plug>(vimfiler_execute_shell_command)  :<C-u>call vimfiler#mappings#execute_shell_command()<CR>
nnoremap <silent> <Plug>(vimfiler_exit)  :<C-u>call vimfiler#mappings#exit()<CR>
nnoremap <silent> <Plug>(vimfiler_help)  :<C-u>nnoremap <buffer><CR>
nnoremap <silent> <Plug>(vimfiler_preview_file)  :<C-u>call vimfiler#mappings#preview_file()<CR>
nnoremap <silent> <Plug>(vimfiler_sync_with_current_vimfiler)  :<C-u>call vimfiler#mappings#sync_with_current_vimfiler()<CR>
nnoremap <silent> <Plug>(vimfiler_sync_with_another_vimfiler)  :<C-u>call vimfiler#mappings#sync_with_another_vimfiler()<CR>
nnoremap <silent> <Plug>(vimfiler_print_filename)  :<C-u>echo vimfiler#get_filename(line('.'))<CR>
nnoremap <silent> <Plug>(vimfiler_paste_from_clipboard)  :<C-u>call vimfiler#mappings#paste_from_clipboard()<CR>
nnoremap <silent> <Plug>(vimfiler_set_current_mask)  :<C-u>call vimfiler#mappings#set_current_mask()<CR>
nnoremap <silent> <Plug>(vimfiler_restore_from_trashbox)  :<C-u>call vimfiler#mappings#restore_from_trashbox()<CR>
nnoremap <silent> <Plug>(vimfiler_grep)  :<C-u>call vimfiler#mappings#grep()<CR>
nnoremap <silent> <Plug>(vimfiler_select_sort_type)  :<C-u>call vimfiler#mappings#select_sort_type()<CR>

nnoremap <silent> <Plug>(vimfiler_copy_file)  :<C-u>call vimfiler#mappings#copy()<CR>
nnoremap <silent> <Plug>(vimfiler_move_file)  :<C-u>call vimfiler#mappings#move()<CR>
nnoremap <silent> <Plug>(vimfiler_delete_file)  :<C-u>call vimfiler#mappings#delete()<CR>
nnoremap <silent> <Plug>(vimfiler_force_delete_file)  :<C-u>call vimfiler#mappings#force_delete()<CR>
nnoremap <silent> <Plug>(vimfiler_rename_file)  :<C-u>call vimfiler#mappings#rename()<CR>
nnoremap <silent> <Plug>(vimfiler_make_directory)  :<C-u>call vimfiler#mappings#make_directory()<CR>
nnoremap <silent> <Plug>(vimfiler_new_file)  :<C-u>call vimfiler#mappings#new_file()<CR>
"}}}

augroup vimfiler"{{{
  autocmd!
augroup end"}}}

" User utility functions."{{{
function! vimfiler#default_settings()"{{{
  setlocal buftype=nofile
  setlocal noswapfile
  setlocal bufhidden=hide
  setlocal nomodifiable
  setlocal nowrap
  setlocal cursorline
  if has('netbeans_intg') || has('sun_workshop')
    setlocal noautochdir
  endif
  let &l:winwidth = g:vimfiler_min_filename_width + 10

  " Set autocommands.
  augroup vimfiler"{{{
    autocmd BufWinEnter <buffer> call s:event_bufwin_enter()
    autocmd WinLeave,BufWinLeave <buffer> call s:event_bufwin_leave()
    autocmd VimResized <buffer> call vimfiler#redraw_all_vimfiler()
  augroup end"}}}

  " Define key-mappings."{{{
  if !(exists('g:vimfiler_no_default_key_mappings') && g:vimfiler_no_default_key_mappings)
    nmap <buffer> <TAB> <C-w>w
    nmap <buffer> j <Plug>(vimfiler_loop_cursor_down)
    nmap <buffer> k <Plug>(vimfiler_loop_cursor_up)

    " Toggle mark.
    nmap <buffer> <C-l> <Plug>(vimfiler_redraw_screen)
    nmap <buffer> <Space> <Plug>(vimfiler_toggle_mark_current_line)

    " Toggle mark in all lines.
    nmap <buffer> * <Plug>(vimfiler_toggle_mark_all_lines)

    " Copy.
    nmap <buffer> c <Plug>(vimfiler_copy_file)
    
    " Move.
    nmap <buffer> m <Plug>(vimfiler_move_file)
    
    " Delete.
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
    nmap <buffer> l <Plug>(vimfiler_execute)

    nmap <buffer> x <Plug>(vimfiler_execute_file)
    nmap <buffer> h <Plug>(vimfiler_move_to_up_directory)
    nmap <buffer> L <Plug>(vimfiler_move_to_drive)
    nmap <buffer> J <Plug>(vimfiler_jump_to_directory)
    nmap <buffer> ~ <Plug>(vimfiler_move_to_home_directory)
    nmap <buffer> $ <Plug>(vimfiler_move_to_trashbox_directory)
    nmap <buffer> \ <Plug>(vimfiler_move_to_root_directory)
    nmap <buffer> gv <Plug>(vimfiler_execute_new_gvim)
    nmap <buffer> . <Plug>(vimfiler_toggle_visible_dot_files)
    nmap <buffer> H <Plug>(vimfiler_popup_shell)
    nmap <buffer> e <Plug>(vimfiler_edit_file)
    nmap <buffer> E <Plug>(vimfiler_execute_external_filer)
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
    nmap <buffer> s <Plug>(vimfiler_select_sort_type)
  endif
  "}}}
endfunction"}}}
function! vimfiler#set_execute_file(exts, program)"{{{
  for ext in split(a:exts, ',')
    let g:vimfiler_execute_file_list[ext] = a:program
  endfor
endfunction"}}}
"}}}

" vimfiler plugin utility functions."{{{
function! vimfiler#create_filer(directory, options)"{{{
  if a:directory != '' && !isdirectory(a:directory)
    echohl Error | echomsg 'Invalid directory name: ' . a:directory | echohl None
    return
  endif

  " Check options.
  let l:split_flag = 0
  let l:overwrite_flag = 0
  let l:simple_flag = 0
  for l:option in a:options
    if l:option ==# 'split'
      let l:split_flag = 1
    elseif l:option ==# 'overwrite'
      let l:overwrite_flag = 1
    elseif l:option ==# 'simple'
      let l:simple_flag = 1
    endif
  endfor
  
  if !l:overwrite_flag
    " Create new buffer.
    let l:bufname = '[1]vimfiler'
    let l:cnt = 2
    while buflisted(l:bufname)
      let l:bufname = printf('[%d]vimfiler', l:cnt)
      let l:cnt += 1
    endwhile

    if l:split_flag
      vsplit `=l:bufname`
    else
      edit `=l:bufname`
    endif
  endif

  call vimfiler#default_settings()
  setfiletype vimfiler

  let b:vimfiler = {}

  " Set current directory.
  let l:current = (a:directory != '')? a:directory : getcwd()
  lcd `=l:current`
  let b:vimfiler.current_dir = l:current
  if b:vimfiler.current_dir !~ '/$'
    let b:vimfiler.current_dir .= '/'
  endif
  let b:vimfiler.clipboard = {}
  let b:vimfiler.is_visible_dot_files = 0
  let b:vimfiler.is_simple = l:simple_flag
  let b:vimfiler.directory_cursor_pos = {}
  " Set mask.
  let b:vimfiler.current_mask = '*'
  let b:vimfiler.sort_type = g:vimfiler_sort_type

  call vimfiler#force_redraw_screen()
endfunction"}}}
function! vimfiler#switch_filer(directory, options)"{{{
  if a:directory != '' && !isdirectory(a:directory)
    echohl Error | echomsg 'Invalid directory name: ' . a:directory | echohl None
    return
  endif
  
  let l:split_flag = 0
  for l:option in a:options
    if l:option ==# 'split'
      let l:split_flag = 1
    endif
  endfor
  
  if &filetype ==# 'vimfiler'
    if winnr('$') != 1
      close
    else
      buffer #
    endif

    if a:directory != ''
      " Change current directory.
      let b:vimfiler.current_dir = a:directory
      if b:vimfiler.current_dir !~ '/$'
        let b:vimfiler.current_dir .= '/'
      endif
    endif

    call vimfiler#force_redraw_screen()
    return
  endif

  " Search vimfiler window.
  let l:cnt = 1
  while l:cnt <= winnr('$')
    if getwinvar(l:cnt, '&filetype') ==# 'vimfiler'

      execute l:cnt . 'wincmd w'

      if a:directory != ''
        " Change current directory.
        let b:vimfiler.current_dir = a:directory
        if b:vimfiler.current_dir !~ '/$'
          let b:vimfiler.current_dir .= '/'
        endif
      endif

      call vimfiler#force_redraw_screen()
      return
    endif

    let l:cnt += 1
  endwhile

  " Search vimfiler buffer.
  let l:cnt = 1
  while l:cnt <= bufnr('$')
    if getbufvar(l:cnt, '&filetype') ==# 'vimfiler'
      if l:split_flag
        execute 'sbuffer' . l:cnt
      else
        execute 'buffer' . l:cnt
      endif

      if a:directory != ''
        " Change current directory.
        let b:vimfiler.current_dir = a:directory
        if b:vimfiler.current_dir !~ '/$'
          let b:vimfiler.current_dir .= '/'
        endif
      endif

      call vimfiler#force_redraw_screen()
      return
    endif

    let l:cnt += 1
  endwhile

  " Create window.
  call vimfiler#create_filer(a:directory, a:options)
endfunction"}}}
function! vimfiler#force_redraw_screen()"{{{
  " Save current files.
  let l:current_files = []
  for l:mask in split(b:vimfiler.current_mask)
    let l:current_files += split(glob(b:vimfiler.current_dir . l:mask), '\n')
  endfor
  if b:vimfiler.is_visible_dot_files
    for l:mask in split(b:vimfiler.current_mask)
      let l:current_files += filter(split(glob(b:vimfiler.current_dir . '.' . l:mask), '\n'), 
            \'v:val !~ "[/\\\\]\.\.\\?$"')
    endfor
  endif
  
  let l:dirs = []
  let l:files = []
  for l:file in l:current_files
    if isdirectory(l:file)
      call add(l:dirs, {
          \ 'name' : l:file, 
          \ 'extension' : '', 
          \ 'type' : '[DIR]', 
          \ 'size' : 0, 
          \ 'datemark' : vimfiler#get_datemark(l:file), 
          \ 'time' : getftime(l:file), 
          \ 'is_directory' : 1, 'is_marked' : 0, 
          \ })
    else
      call add(l:files, {
          \ 'name' : l:file, 
          \ 'extension' : fnamemodify(l:file, ':e'), 
          \ 'type' : vimfiler#get_filetype(l:file), 
          \ 'size' : getfsize(l:file), 
          \ 'datemark' : vimfiler#get_datemark(l:file), 
          \ 'time' : getftime(l:file), 
          \ 'is_directory' : 0, 'is_marked' : 0, 
          \ })
    endif
  endfor
  if g:vimfiler_directory_display_top
    let b:vimfiler.current_files = vimfiler#sort(l:dirs, b:vimfiler.sort_type)
          \+ vimfiler#sort(l:files, b:vimfiler.sort_type)
  else
    let b:vimfiler.current_files = vimfiler#sort(l:files + l:dirs, b:vimfiler.sort_type)
  endif

  call vimfiler#redraw_screen()
endfunction"}}}
function! vimfiler#redraw_screen()"{{{
  if !has_key(b:vimfiler, 'current_files')
    return
  endif

  setlocal modifiable
  let l:pos = getpos('.')

  " Clean up the screen.
  % delete _

  " Print current directory.
  call setline(1, (b:vimfiler.is_simple ? 'CD: ' : 'Current directory: ')
        \. b:vimfiler.current_dir . b:vimfiler.current_mask)

  " Append up directory.
  call append('$', '..')

  " Print files.
  let l:max_len = b:vimfiler.is_simple ? 
        \ g:vimfiler_min_filename_width : (winwidth(winnr()) - g:vimfiler_min_filename_width)
  if l:max_len > g:vimfiler_max_filename_width
    let l:max_len = g:vimfiler_max_filename_width
  endif
  for l:file in b:vimfiler.current_files
    let l:filename = fnamemodify(l:file.name, ':t')
    if l:file.is_directory
      let l:filename .= '/'
    endif
    if l:filename =~ '[^[:print:]]'
      " Multibyte.
      let l:filename = vimfiler#smart_omit_filename(l:filename, l:max_len)
    elseif len(l:filename) > l:max_len
      let l:filename = l:filename[: l:max_len - 4] . '...'
    else
      let l:filename .= repeat(' ', l:max_len - len(l:filename))
    endif

    let l:mark = l:file.is_marked ? '*' : '-'
    if !b:vimfiler.is_simple
      if l:file.is_directory
        let l:line = printf('%s %s [DIR]         %s',
              \ l:mark, l:filename, 
              \ l:file.datemark . strftime('%y/%m/%d %H:%M', l:file.time)
              \)
      else
        let l:line = printf('%s %s %s %s %s',
              \ l:mark, 
              \ l:filename, 
              \ l:file.type, 
              \ vimfiler#get_filesize(l:file.size), 
              \ l:file.datemark . strftime('%y/%m/%d %H:%M', l:file.time)
              \)
      endif
    elseif l:file.is_directory
      let l:line = printf('%s %s [DIR]', l:mark, l:filename)
    else
      let l:line = printf('%s %s %s', l:mark, l:filename, l:file.type)
    endif
    
    call append('$', l:line)
  endfor
  
  call setpos('.', l:pos)
  setlocal nomodifiable
endfunction"}}}
function! vimfiler#iswin()"{{{
  return has('win32') || has('win64')
endfunction"}}}
function! vimfiler#is_vimproc()"{{{
  return s:is_vimproc
endfunction"}}}
function! vimfiler#system(str, ...)"{{{
  let l:command = a:str
  let l:input = join(a:000)
  if &termencoding != '' && &termencoding != &encoding
    let l:command = iconv(l:command, &encoding, &termencoding)
    let l:input = iconv(l:input, &encoding, &termencoding)
  endif
  let l:output = s:is_vimproc ? (a:0 == 0 ? vimproc#system(l:command) : vimproc#system(l:command, l:input))
        \: (a:0 == 0 ? system(l:command) : system(l:command, l:input))
  if &termencoding != '' && &termencoding != &encoding
    let l:output = iconv(l:output, &termencoding, &encoding)
  endif
  return l:output
endfunction"}}}
function! vimfiler#force_system(str, ...)"{{{
  let l:command = a:str
  let l:input = join(a:000)
  if &termencoding != '' && &termencoding != &encoding
    let l:command = iconv(l:command, &encoding, &termencoding)
    let l:input = iconv(l:input, &encoding, &termencoding)
  endif
  let l:output = (a:0 == 0)? system(l:command) : system(l:command, l:input)
  if &termencoding != '' && &termencoding != &encoding
    let l:output = iconv(l:output, &termencoding, &encoding)
  endif
  return l:output
endfunction"}}}
function! vimfiler#get_marked_files()"{{{
  let l:files = []
  let l:max = line('$')
  let l:cnt = 1
  while l:cnt <= l:max
    let l:line = getline(l:cnt)
    if l:line =~ '^[*] '
      " Marked.
      call add(l:files, vimfiler#get_file(l:cnt))
    endif

    let l:cnt += 1
  endwhile

  return l:files
endfunction"}}}
function! vimfiler#get_marked_filenames()"{{{
  let l:files = []
  let l:max = line('$')
  let l:cnt = 1
  while l:cnt <= l:max
    let l:line = getline(l:cnt)
    if l:line =~ '^[*] '
      " Marked.
      call add(l:files, vimfiler#get_filename(l:cnt))
    endif

    let l:cnt += 1
  endwhile

  return l:files
endfunction"}}}
function! vimfiler#get_escaped_marked_files()"{{{
  let l:files = []
  let l:max = line('$')
  let l:cnt = 1
  while l:cnt <= l:max
    let l:line = getline(l:cnt)
    if l:line =~ '^[*] '
      " Marked.
      call add(l:files, '"' . vimfiler#get_filename(l:cnt) . '"')
    endif

    let l:cnt += 1
  endwhile

  return l:files
endfunction"}}}
function! vimfiler#get_escaped_files(list)"{{{
  return 
endfunction"}}}
function! vimfiler#check_filename_line(...)"{{{
  let l:line = (a:0 == 0)? getline('.') : a:1
  return l:line =~ '^[*-]\s'
endfunction"}}}
function! vimfiler#get_filename(line_num)"{{{
  return getline(a:line_num) == '..'? '..' : b:vimfiler.current_files[a:line_num - 3].name
endfunction"}}}
function! vimfiler#get_file(line_num)"{{{
  return getline(a:line_num) == '..'? {} : b:vimfiler.current_files[a:line_num - 3]
endfunction"}}}
function! vimfiler#input_directory(message)"{{{
  echo a:message
  let l:dir = input('', '', 'dir')
  while !isdirectory(l:dir)
    redraw
    if l:dir == ''
      echo 'Canceled.'
      break
    endif

    " Retry.
    echohl WarningMsg | echo 'Invalid path.' | echohl None
    echo a:message
    let l:dir = input('', '', 'dir')
  endwhile

  return l:dir
endfunction"}}}
function! vimfiler#input_yesno(message)"{{{
  let l:yesno = input(a:message . ' [yes/no] :   ')
  while l:yesno !~? '^\%(y\%[es]\|n\%[o]\)$'
    redraw
    if l:yesno == ''
      echo 'Canceled.'
      break
    endif

    " Retry.
    echohl WarningMsg | echo 'Invalid input.' | echohl None
    let l:yesno = input(a:message . ' [yes/no] :   ')
  endwhile

  return l:yesno
endfunction"}}}
function! vimfiler#force_redraw_all_vimfiler()"{{{
  let l:current_nr = winnr()
  let l:bufnr = 1
  while l:bufnr <= winnr('$')
    " Search vimfiler window.
    if getwinvar(l:bufnr, '&filetype') ==# 'vimfiler'

      execute l:bufnr . 'wincmd w'
      call vimfiler#force_redraw_screen()
    endif

    let l:bufnr += 1
  endwhile

  execute l:current_nr . 'wincmd w'
endfunction"}}}
function! vimfiler#redraw_all_vimfiler()"{{{
  let l:current_nr = winnr()
  let l:bufnr = 1
  while l:bufnr <= winnr('$')
    " Search vimfiler window.
    if getwinvar(l:bufnr, '&filetype') ==# 'vimfiler'

      execute l:bufnr . 'wincmd w'
      call vimfiler#redraw_screen()
    endif

    let l:bufnr += 1
  endwhile

  execute l:current_nr . 'wincmd w'
endfunction"}}}
function! vimfiler#smart_omit_filename(filename, length)"{{{
  let l:len = len(a:filename)

  " For multibyte.
  let l:pos = 0
  let l:fchar = char2nr(a:filename[l:pos])
  let l:display_diff = 0
  while l:pos < l:len && l:pos-l:display_diff < a:length
    if l:fchar >= 0x80
      " Skip multibyte
      if l:fchar < 0xc0
        " Skip UTF-8 on the way
        let l:fchar = char2nr(a:filename[l:pos])
        while l:pos < a:length && 0x80 <= l:fchar && l:fchar < 0xc0
          let l:pos += 1
          let l:fchar = char2nr(a:filename[l:pos])
        endwhile
      elseif l:fchar < 0xe0
        " 2byte code
        let l:pos += 1
      elseif l:fchar < 0xf0
        " 3byte code
        let l:display_diff += 1
        let l:pos += 2
      elseif l:fchar < 0xf8
        " 4byte code
        let l:display_diff += 2
        let l:pos += 3
      elseif l:fchar < 0xfe
        " 5byte code
        let l:display_diff += 3
        let l:pos += 4
      else
        " 6byte code
        let l:display_diff += 4
        let l:pos += 5
      endif
    endif

    let l:pos += 1
    let l:fchar = char2nr(a:filename[l:pos])
  endwhile

  if l:pos > a:length
    return a:filename[: l:pos] . '...'
  else
    return a:filename[: l:pos] . repeat(' ', a:length - l:pos+l:display_diff)
  endif
endfunction"}}}
function! vimfiler#get_filetype(filename)"{{{
  let l:ext = fnamemodify(a:filename, ':e')
  if isdirectory(a:filename)
    return '[DIR]'
  elseif l:ext =~? 
        \'^\%(txt\|cfg\|ini\)$'
    " Text.
    return '[TXT]'
  elseif l:ext =~?
        \'^\%(bmp\|png\|gif\|jpg\|jpeg\|jp2\|tif\|ico\|wdp\|cur\|ani\)$'
    " Image.
    return '[IMG]'
  elseif l:ext =~? 
        \'^\%(lzh\|zip\|gz\|bz2\|cab\|rar\|7z\|tgz\|tar\)$'
    " Archive.
    return '[ARC]'
  elseif (!vimfiler#iswin() && executable(a:filename))
        \|| l:ext =~? 
        \'^\%(exe\|com\|bat\|cmd\|vbs\|vbe\|js\|jse\|wsf\|wsh\|msc\|pif\|msi\|ps1\)$'
    " Execute.
    return '[EXE]'
  elseif l:ext =~?
        \'^\%(avi\|asf\|wmv\|mpg\|flv\|swf\|divx\|mov\|mpa\|m1a\|m2p\|m2a\|mpeg\|m1v\|m2v\|mp2v\|mp4\|qt\|ra\|rm\|ram\|rmvb\|rpm\|smi\|mkv\|mid\|wav\|mp3\|ogg\|wma\|au\)$'
    " Multimedia.
    return '[MUL]'
  elseif a:filename =~ '^\.' || l:ext =~? 
        \'^\%(inf\|sys\|reg\|dat\|spi\|a\|so\|lib\)$'
    " System.
    return '[SYS]'
  else
    " Others filetype.
    return '     '
  endif
endfunction"}}}
function! vimfiler#get_filesize(size)"{{{
  " Get human file size.
  if a:size < 0
    " Above 2GB.
    let l:suffix = 'G'
    let l:mega = (a:size+1073741824+1073741824) / 1024 / 1024
    let l:float = (l:mega%1024)*100/1024
    let l:pattern = printf('%d.%d', 2+l:mega/1024, l:float)
  elseif a:size >= 1073741824
    " GB.
    let l:suffix = 'G'
    let l:mega = a:size / 1024 / 1024
    let l:float = (l:mega%1024)*100/1024
    let l:pattern = printf('%d.%d', l:mega/1024, l:float)
  elseif a:size >= 1048576
    " MB.
    let l:suffix = 'M'
    let l:kilo = a:size / 1024
    let l:float = (l:kilo%1024)*100/1024
    let l:pattern = printf('%d.%d', l:kilo/1024, l:float)
  elseif a:size >= 1024
    " KB.
    let l:suffix = 'K'
    let l:float = (a:size%1024)*100/1024
    let l:pattern = printf('%d.%d', a:size/1024, l:float)
  else
    " B.
    let l:suffix = 'B'
    let l:float = ''
    let l:pattern = printf('%6d', a:size)
  endif

  return printf('%s%s%s', l:pattern[:5], repeat(' ', 6-len(l:pattern)), l:suffix)
endfunction"}}}
function! vimfiler#get_datemark(filename)"{{{
  let l:time = localtime() - getftime(a:filename)
  if l:time < 86400
    " 60 * 60 * 24
    return '!'
  elseif l:time < 604800
    " 60 * 60 * 24 * 7
    return '#'
  else
    return '~'
  endif
endfunction"}}}
function! vimfiler#head_match(checkstr, headstr)"{{{
  return a:headstr == '' || a:checkstr ==# a:headstr
        \|| a:checkstr[: len(a:headstr)-1] ==# a:headstr
endfunction"}}}
function! vimfiler#exists_another_vimfiler()"{{{
  let l:winnr = bufwinnr(s:last_vimfiler_bufnr)
  return l:winnr > 0 && winnr() != l:winnr && getwinvar(l:winnr, '&filetype') ==# 'vimfiler'
endfunction"}}}
function! vimfiler#bufnr_another_vimfiler()"{{{
  return vimfiler#exists_another_vimfiler() ?
        \ s:last_vimfiler_bufnr : -1
endfunction"}}}
function! vimfiler#winnr_another_vimfiler()"{{{
  return vimfiler#exists_another_vimfiler() ?
        \ bufwinnr(s:last_vimfiler_bufnr) : -1
endfunction"}}}
function! vimfiler#get_another_vimfiler()"{{{
  return vimfiler#exists_another_vimfiler() ?
        \ getbufvar(s:last_vimfiler_bufnr), 'vimfiler') : ''
endfunction"}}}
"}}}

" Detect drives.
function! vimfiler#detect_drives()"{{{
  " Initialize.
  let s:drives = {}

  if vimfiler#iswin()
    " Detect drive.
    for l:drive in g:vimfiler_detect_drives
      if isdirectory(l:drive . ':/')
        let s:drives[tolower(l:drive)] = l:drive . ':/'
      endif
    endfor
  else
    let l:drive_key = 'abcdefghijklmnopqrstuvwxyz'

    if has('macunix') || system('uname') =~? '^darwin'
      let l:drive_list = split(glob('/Volumes/*'), '\n')
    else
      let l:drive_list = split(glob('/mnt/*'), '\n') + split(glob('/media/*'), '\n')
    endif
    " Detect mounted drive.
    let l:cnt = 0
    for l:drive in l:drive_list[:25]
      let s:drives[l:drive_key[l:cnt]] = l:drive

      let l:cnt += 1
    endfor
  endif
endfunction"}}}
function! vimfiler#get_drives()"{{{
  if !exists('s:drives')
    call vimfiler#detect_drives()
  endif

  return s:drives
endfunction"}}}

" Sort.
function! vimfiler#sort(files, type)"{{{
  if a:type =~? '^n\%[one]$'
    " Ignore.
    let l:files = a:files
  elseif a:type =~? '^s\%[ize]$'
    let l:files = sort(a:files, 's:compare_size')
  elseif a:type =~? '^e\%[xtension]$'
    let l:files = sort(a:files, 's:compare_extension')
  elseif a:type =~? '^f\%[ilename]$'
    let l:files = sort(a:files, 's:compare_name')
  elseif a:type =~? '^t\%[ime]$'
    let l:files = sort(a:files, 's:compare_time')
  elseif a:type =~? '^m\%[anual]$'
    " Not implemented.
    let l:files = a:files
  else
    throw 'Invalid sort type.'
  endif

  if a:type =~ '^\u'
    " Reverse order.
    let l:files = reverse(l:files)
  endif

  return l:files
endfunction"}}}
function! s:compare_size(i1, i2)"{{{
  return a:i1.size > a:i2.size ? 1 : a:i1.size == a:i2.size ? 0 : -1
endfunction"}}}
function! s:compare_extension(i1, i2)"{{{
  return a:i1.extension > a:i2.extension ? 1 : a:i1.extension == a:i2.extension ? 0 : -1
endfunction"}}}
function! s:compare_name(i1, i2)"{{{
  return a:i1.name > a:i2.name ? 1 : a:i1.name == a:i2.name ? 0 : -1
endfunction"}}}
function! s:compare_time(i1, i2)"{{{
  return a:i1.time > a:i2.time ? 1 : a:i1.time == a:i2.time ? 0 : -1
endfunction"}}}

" Event functions.
function! s:event_bufwin_enter()"{{{
  lcd `=b:vimfiler.current_dir`
  call vimfiler#redraw_screen()
endfunction"}}}
function! s:event_bufwin_leave()"{{{
  let s:last_vimfiler_bufnr = bufnr('%')
endfunction"}}}

" vim: foldmethod=marker

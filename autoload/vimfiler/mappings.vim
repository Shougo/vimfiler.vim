"=============================================================================
" FILE: mappings.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>(Modified)
" Last Modified: 03 Mar 2010
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

" vimfiler key-mappings functions.
function! vimfiler#mappings#loop_cursor_down()"{{{
  if line('.') == line('$')
    0
  else
    normal! j
  endif
endfunction"}}}
function! vimfiler#mappings#loop_cursor_up()"{{{
  if line('.') == 1
    $
  else
    normal! k
  endif
endfunction"}}}
function! vimfiler#mappings#toggle_mark_current_line()"{{{
  let l:line = getline('.')
  if l:line == '..' || !vimfiler#check_filename_line(l:line)
    " Don't toggle.
    return
  endif
  setlocal modifiable

  let l:file = vimfiler#get_file(line('.'))
  let l:file.is_marked = !l:file.is_marked
  call vimfiler#redraw_screen()

  setlocal nomodifiable
endfunction"}}}
function! vimfiler#mappings#toggle_mark_all_lines()"{{{
  setlocal modifiable

  let l:max = line('$')
  let l:cnt = 1
  while l:cnt <= l:max
    let l:line = getline(l:cnt)
    if l:line != '..' && vimfiler#check_filename_line(l:line)
      " Toggle mark.

      let l:file = vimfiler#get_file(l:cnt)
      let l:file.is_marked = !l:file.is_marked
    endif

    let l:cnt += 1
  endwhile
  call vimfiler#redraw_screen()

  setlocal nomodifiable
endfunction"}}}
function! vimfiler#mappings#clear_mark_all_lines()"{{{
  setlocal modifiable

  let l:max = line('$')
  let l:cnt = 1
  while l:cnt <= l:max
    let l:line = getline(l:cnt)
    if l:line != '..' && vimfiler#check_filename_line(l:line)
      " Clear mark.

      let l:file = vimfiler#get_file(l:cnt)
      let l:file.is_marked = 0
    endif

    let l:cnt += 1
  endwhile
  call vimfiler#redraw_screen()

  setlocal nomodifiable
endfunction"}}}
function! vimfiler#mappings#copy()"{{{
  let l:marked_files = vimfiler#get_marked_files()
  if empty(l:marked_files)
    " Mark current line.
    call vimfiler#mappings#toggle_mark_current_line()
    return
  endif

  " Get destination directory.
  let l:dest_dir = vimfiler#get_alternate_directory()
  if l:dest_dir == ''
    let l:dest_dir = vimfiler#input_directory('Please input destination directory:')
    if l:dest_dir == ''
      " Cancel.
      return
    endif
  endif

  " Execute copy.
  call vimfiler#internal_commands#cp(l:dest_dir, l:marked_files)
  call vimfiler#mappings#clear_mark_all_lines()
  call vimfiler#redraw_alternate_vimfiler()
endfunction"}}}
function! vimfiler#mappings#execute()"{{{
  let l:line = getline('.')
  if !vimfiler#check_filename_line(l:line)
    let l:cursor_line = matchstr(l:line[: col('.') - 1], '^Current directory: \zs.*')
    if l:cursor_line != ''
      " Change current directory.
      let l:cursor_next = matchstr(l:line[col('.') :], '.\{-}\ze[/\\]')

      call vimfiler#internal_commands#cd(l:cursor_line . l:cursor_next)
    endif

    return
  endif

  let l:filename = vimfiler#get_filename(line('.'))
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
        call vimfiler#mappings#edit_file()
      else
        call vimfiler#internal_commands#gexe(printf('%s %s%s%s', g:vimfiler_execute_file_list[l:ext], &shellquote, l:filename, &shellquote))
      endif
    endif
  endif
endfunction"}}}
function! vimfiler#mappings#execute_file()"{{{
  let l:line = getline('.')
  if !vimfiler#check_filename_line(l:line)
    return
  endif

  let l:filename = vimfiler#get_filename(line('.'))
  " Execute cursor file.
  call vimfiler#internal_commands#open(l:filename)
endfunction"}}}
function! vimfiler#mappings#move_to_drive()"{{{
  if !exists('s:drives')
    " Initialize.
    let s:drives = {}

    if vimfiler#iswin()
      " Detect drive.
      for l:drive in ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 
            \ 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S',
            \ 'T', 'U', 'V', 'W', 'X', 'Y', 'Z']
        if !empty(glob(l:drive . ':/'))
          let s:drives[tolower(l:drive)] = l:drive . ':/'
        endif
      endfor
    else
      let l:drive_key = 'abcdefghijklmnopqrstuvwxyz'

      if has('mac')
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
  endif

  if empty(s:drives)
    " No drives.
    return
  endif

  for [l:key, l:drive] in items(s:drives)
    echo printf('[%s] %s', l:key, l:drive)
  endfor

  let l:key = tolower(input('Please input drive alphabet or other directory: ', '', 'dir'))
  if l:key != '' && has_key(s:drives, l:key)
    call vimfiler#internal_commands#cd(s:drives[l:key])
  elseif isdirectory(expand(l:key))
    call vimfiler#internal_commands#cd(expand(l:key))
  endif
endfunction"}}}
function! vimfiler#mappings#move_to_current_directory()"{{{
  let b:vimfiler.save_current_dir = b:vimfiler.current_dir
endfunction"}}}
function! vimfiler#mappings#toggle_visible_dot_files()"{{{
  let b:vimfiler.is_visible_dot_files = !b:vimfiler.is_visible_dot_files
  call vimfiler#redraw_screen()
endfunction"}}}
function! vimfiler#mappings#popup_shell()"{{{
  if exists(':VimShellPop')
    VimShellPop `=b:vimfiler.current_dir`
  else
    " Run shell.
    let l:save_currnet_dir = getcwd()
    shell
  endif
endfunction"}}}
function! vimfiler#mappings#edit_file()"{{{
  if !vimfiler#check_filename_line(getline('.'))
    return
  endif

  " Split nicely.
  if winheight(0) > &winheight
    split
  else
    vsplit
  endif

  try
    edit `=vimfiler#get_filename(line('.'))`
  catch
    echohl Error | echomsg v:errmsg | echohl None
  endtry
endfunction"}}}
function! vimfiler#mappings#preview_file()"{{{
  if !vimfiler#check_filename_line(getline('.'))
    return
  endif

  try
    pedit `=vimfiler#get_filename(line('.'))`
  catch
    echohl Error | echomsg v:errmsg | echohl None
  endtry
endfunction"}}}
function! vimfiler#mappings#execute_external_command()"{{{
  let l:command = input('Input external command: ', '', 'shellcmd')
  if l:command == ''
    echo 'Canceled.'
    return
  endif

  call vimfiler#internal_commands#gexe(l:command)
endfunction"}}}

" vim: foldmethod=marker

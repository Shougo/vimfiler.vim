"=============================================================================
" FILE: mappings.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 06 May 2010
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
  if !vimfiler#check_filename_line()
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
    if vimfiler#check_filename_line(l:line)
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
    if vimfiler#check_filename_line(l:line)
      " Clear mark.

      let l:file = vimfiler#get_file(l:cnt)
      let l:file.is_marked = 0
    endif

    let l:cnt += 1
  endwhile
  call vimfiler#redraw_screen()

  setlocal nomodifiable
endfunction"}}}
function! vimfiler#mappings#execute()"{{{
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
  let l:filename = vimfiler#get_filename(line('.'))
  if l:filename != '..' && !vimfiler#check_filename_line()
    return
  endif

  " Execute cursor file.
  call vimfiler#internal_commands#open(l:filename)
endfunction"}}}
function! vimfiler#mappings#move_to_drive()"{{{
  if !exists('s:drives')"{{{
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
  endif"}}}

  if empty(s:drives)
    " No drives.
    return
  endif

  for [l:key, l:drive] in items(s:drives)
    echo printf('[%s] %s', l:key, l:drive)
  endfor

  let l:key = tolower(input('Please input drive alphabet or other directory: ', '', 'dir'))
  if l:key == ''
    echo 'Canceled.'
    return
  elseif has_key(s:drives, l:key)
    call vimfiler#internal_commands#cd(s:drives[l:key])
  elseif isdirectory(expand(l:key))
    call vimfiler#internal_commands#cd(expand(l:key))
  else
    echo 'Invalid directory name.'
    return
  endif
endfunction"}}}
function! vimfiler#mappings#jump_to_directory()"{{{
  let l:dir = input('Jump to: ', '', 'dir')
  if l:dir == ''
    echo 'Canceled.'
    return
  elseif isdirectory(expand(l:dir))
    call vimfiler#internal_commands#cd(expand(l:dir))
  else
    echo 'Invalid directory name.'
    return
  endif
endfunction"}}}

function! vimfiler#mappings#toggle_visible_dot_files()"{{{
  let b:vimfiler.is_visible_dot_files = !b:vimfiler.is_visible_dot_files
  call vimfiler#force_redraw_screen()
endfunction"}}}
function! vimfiler#mappings#popup_shell()"{{{
  if exists(':VimShellPop')
    let l:files = join(vimfiler#get_escaped_marked_files())
    call vimfiler#mappings#clear_mark_all_lines()
    
    VimShellPop `=b:vimfiler.current_dir`
    
    if l:files != ''
      call setline(line('.'), getline('.') . ' ' . l:files)
      normal! l
    endif
  else
    " Run shell.
    let l:save_currnet_dir = getcwd()
    shell
  endif
endfunction"}}}
function! vimfiler#mappings#edit_file()"{{{
  if !vimfiler#check_filename_line()
    return
  endif

  call vimfiler#internal_commands#edit(vimfiler#get_filename(line('.')))
endfunction"}}}
function! vimfiler#mappings#preview_file()"{{{
  if !vimfiler#check_filename_line()
    return
  endif

  call vimfiler#internal_commands#pedit(vimfiler#get_filename(line('.')))
endfunction"}}}
function! vimfiler#mappings#execute_external_command()"{{{
  let l:command = input('Input external command: ', '', 'shellcmd')
  if l:command == ''
    echo 'Canceled.'
    return
  endif

  call vimfiler#internal_commands#gexe(l:command)
endfunction"}}}
function! vimfiler#mappings#execute_shell_command()"{{{
  let l:command = input('Input shell command: ', '', 'shellcmd')
  if l:command == ''
    echo 'Canceled.'
    return
  endif

  let l:command = substitute(l:command, 
        \'\s\+\zs\*\ze\%([;|[:space:]]\|$\)', join(vimfiler#get_escaped_marked_files()), 'g')
  echo vimfiler#system(l:command)
endfunction"}}}
function! vimfiler#mappings#exit()"{{{
  let l:vimfiler_buf = bufnr('%')
  " Switch buffer.
  if winnr('$') != 1
    close
  else
    call s:custom_alternate_buffer()
  endif
  execute 'bdelete!'. l:vimfiler_buf
endfunction"}}}
function! vimfiler#mappings#sync_with_current_vimfiler()"{{{
  " Search vimfiler window.
  if winnr('$') == 1 || getwinvar(winnr('#'), '&filetype') !=# 'vimfiler'
    call vimfiler#create_filer(b:vimfiler.current_dir, 
          \b:vimfiler.is_simple ? ['split', 'simple'] : ['split'])
    execute winnr('#') . 'wincmd w'
  else
    " Change another vimfiler directory.
    let l:current_dir = b:vimfiler.current_dir
    execute winnr('#') . 'wincmd w'
    call vimfiler#internal_commands#cd(l:current_dir)
    execute winnr('#') . 'wincmd w'
  endif
endfunction"}}}
function! vimfiler#mappings#sync_with_another_vimfiler()"{{{
  " Search vimfiler window.
  if winnr('$') == 1 || getwinvar(winnr('#'), '&filetype') !=# 'vimfiler'
    call vimfiler#create_filer(b:vimfiler.current_dir, 
          \b:vimfiler.is_simple ? ['split', 'simple'] : ['split'])
    execute winnr('#') . 'wincmd w'
  else
    " Change current vimfiler directory.
    call vimfiler#internal_commands#cd(getbufvar(winbufnr(winnr('#')), 'vimfiler').current_dir)
  endif
endfunction"}}}

function! vimfiler#mappings#move()"{{{
  let l:marked_files = vimfiler#get_marked_files()
  if empty(l:marked_files)
    " Mark current line.
    call vimfiler#mappings#toggle_mark_current_line()
    return
  endif

  " Get destination directory.
  let l:dest_dir = vimfiler#get_alternate_directory()
  if l:dest_dir == ''
    " Copy to clipboard.
    let b:vimfiler.clipboard = {
          \ 'command' : 'move', 'files' : l:marked_files
          \}
    call vimfiler#mappings#clear_mark_all_lines()
    echo 'Saved to clipboard.'
    return
  endif

  let l:yesno = vimfiler#input_yesno('Really move marked files?')

  if l:yesno =~? 'y\%[es]'
    " Execute move.
    call vimfiler#internal_commands#mv(l:dest_dir . '/', l:marked_files)
    call vimfiler#mappings#clear_mark_all_lines()
    call vimfiler#force_redraw_all_vimfiler()
  endif
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
    " Copy to clipboard.
    let b:vimfiler.clipboard = {
          \ 'command' : 'copy', 'files' : l:marked_files
          \}
    call vimfiler#mappings#clear_mark_all_lines()
    echo 'Saved to clipboard.'
    return
  endif

  " Execute copy.
  call vimfiler#internal_commands#cp(l:dest_dir . '/', l:marked_files)
  call vimfiler#mappings#clear_mark_all_lines()
  call vimfiler#force_redraw_all_vimfiler()
endfunction"}}}
function! vimfiler#mappings#delete()"{{{
  let l:marked_files = vimfiler#get_marked_files()
  if empty(l:marked_files)
    " Mark current line.
    call vimfiler#mappings#toggle_mark_current_line()
    return
  endif
  let l:yesno = vimfiler#input_yesno('Really move marked files to trashbox?')

  if l:yesno =~? 'y\%[es]'
    " Execute delete.
    if !isdirectory(g:vimfiler_trashbox_directory)
      call mkdir(g:vimfiler_trashbox_directory, 'p')
    endif
    
    let l:trashdir = g:vimfiler_trashbox_directory . '/' . substitute(strftime('%Y%m%d/%X'), ':', '_', 'g')
    if !isdirectory(l:trashdir)
      call mkdir(l:trashdir, 'p')
    endif
    
    call vimfiler#internal_commands#mv(l:trashdir . '/', l:marked_files)
    call vimfiler#force_redraw_all_vimfiler()
  else
    echo 'Canceled.'
  endif
endfunction"}}}
function! vimfiler#mappings#force_delete()"{{{
  let l:marked_files = vimfiler#get_marked_files()
  if empty(l:marked_files)
    " Mark current line.
    call vimfiler#mappings#toggle_mark_current_line()
    return
  endif
  let l:yesno = vimfiler#input_yesno('Really force delete marked files?')

  if l:yesno =~? 'y\%[es]'
    " Execute force delete.
    call vimfiler#internal_commands#rm(l:marked_files)
    call vimfiler#force_redraw_all_vimfiler()
  else
    echo 'Canceled.'
  endif
endfunction"}}}
function! vimfiler#mappings#rename()"{{{
  if !vimfiler#check_filename_line()
    return
  endif

  let l:oldfilename = vimfiler#get_filename(line('.'))
  let l:filename = input(printf('New filename: %s -> ', l:oldfilename), l:oldfilename, 'file')

  if l:filename == '' || l:filename ==# l:oldfilename
    echo 'Canceled.'
  else
    call rename(l:oldfilename, l:filename)
    call vimfiler#force_redraw_all_vimfiler()
  endif
endfunction"}}}
function! vimfiler#mappings#make_directory()"{{{
  let l:dirname = input('New directory name: ', '', 'dir')

  if l:dirname == ''
    echo 'Canceled.'
  elseif isdirectory(l:dirname) || filereadable(l:dirname)
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
function! vimfiler#mappings#new_file()"{{{
  let l:filename = input('New file name: ', '', 'file')

  if l:filename == ''
    echo 'Canceled.'
  elseif filereadable(l:filename)
    echo 'File exists.'
  else
    call writefile([], l:filename)
    call vimfiler#force_redraw_all_vimfiler()
    call vimfiler#internal_commands#edit(l:filename)
  endif
endfunction"}}}
function! vimfiler#mappings#paste_from_clipboard()"{{{
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
    echoerr 'Invalid command.'
  endif
endfunction"}}}
function! vimfiler#mappings#set_current_mask()"{{{
  let l:mask = input('Please input new mask pattern: ', '')
  if l:mask == ''
    let l:mask = '*'
  endif

  let b:vimfiler.current_mask = l:mask
  call vimfiler#force_redraw_screen()
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
" vim: foldmethod=marker

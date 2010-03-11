"=============================================================================
" FILE: vimfiler.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
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
" Version: 1.50, for Vim 7.0
"=============================================================================

" Check vimproc.
let s:is_vimproc = exists('*vimproc#system')

" Global options definition."{{{
if !exists('g:vimfiler_execute_file_list')
  let g:vimfiler_execute_file_list = {}
endif
"}}}

augroup VimFilerAutoCmd"{{{
  autocmd!
  autocmd BufWinEnter \[*]vimfiler call s:event_bufwin_enter()
  autocmd VimResized \[*]vimfiler call vimfiler#redraw_all_vimfiler()
augroup end"}}}

" Plugin keymappings"{{{
nnoremap <silent> <Plug>(vimfiler_loop_cursor_down)  :<C-u>call vimfiler#mappings#loop_cursor_down()<CR>
nnoremap <silent> <Plug>(vimfiler_loop_cursor_up)  :<C-u>call vimfiler#mappings#loop_cursor_up()<CR>
nnoremap <silent> <Plug>(vimfiler_redraw_screen)  :<C-u>call vimfiler#force_redraw_screen()<CR>
nnoremap <silent> <Plug>(vimfiler_toggle_mark_current_line)  :<C-u>call vimfiler#mappings#toggle_mark_current_line()<CR>j
nnoremap <silent> <Plug>(vimfiler_toggle_mark_all_lines)  :<C-u>call vimfiler#mappings#toggle_mark_all_lines()<CR>
nnoremap <silent> <Plug>(vimfiler_copy)  :<C-u>call vimfiler#mappings#copy()<CR>
nnoremap <silent> <Plug>(vimfiler_execute)  :<C-u>call vimfiler#mappings#execute()<CR>
nnoremap <silent> <Plug>(vimfiler_execute_file)  :<C-u>call vimfiler#mappings#execute_file()<CR>
nnoremap <silent> <Plug>(vimfiler_move_to_up_directory)  :<C-u>call vimfiler#internal_commands#cd('..')<CR>
nnoremap <silent> <Plug>(vimfiler_move_to_home_directory)  :<C-u>call vimfiler#internal_commands#cd('~')<CR>
nnoremap <silent> <Plug>(vimfiler_move_to_root_directory)  :<C-u>call vimfiler#internal_commands#cd('/')<CR>
nnoremap <silent> <Plug>(vimfiler_move_to_drive)  :<C-u>call vimfiler#mappings#move_to_drive()<CR>
nnoremap <silent> <Plug>(vimfiler_execute_new_gvim)  :<C-u>call vimfiler#internal_commands#gexe('gvim')<CR>
nnoremap <silent> <Plug>(vimfiler_toggle_visible_dot_files)  :<C-u>call vimfiler#mappings#toggle_visible_dot_files()<CR>
nnoremap <silent> <Plug>(vimfiler_popup_shell)  :<C-u>call vimfiler#mappings#popup_shell()<CR>
nnoremap <silent> <Plug>(vimfiler_edit_file)  :<C-u>call vimfiler#mappings#edit_file()<CR>
nnoremap <silent> <Plug>(vimfiler_execute_external_filer)  :<C-u>call vimfiler#internal_commands#open(b:vimfiler.current_dir)<CR>
nnoremap <silent> <Plug>(vimfiler_execute_external_command)  :<C-u>call vimfiler#mappings#execute_external_command()<CR>
nnoremap <silent> <Plug>(vimfiler_hide)  :<C-u>buffer #<CR>
nnoremap <silent> <Plug>(vimfiler_help)  :<C-u>nnoremap <buffer><CR>
nnoremap <silent> <Plug>(vimfiler_preview_file)  :<C-u>call vimfiler#mappings#preview_file()<CR>
nnoremap <silent> <Plug>(vimfiler_delete)  :<C-u>call vimfiler#mappings#delete()<CR>
"}}}

" User utility functions."{{{
function! vimfiler#default_settings()"{{{
  setlocal buftype=nofile
  setlocal noswapfile
  setlocal bufhidden=hide
  setlocal nomodifiable
  setlocal nowrap
  setlocal cursorline

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
    nmap <buffer> c <Plug>(vimfiler_copy)
    nmap <buffer> C <Plug>(vimfiler_copy)

    " Execute or change directory.
    nmap <buffer> <Enter> <Plug>(vimfiler_execute)
    nmap <buffer> l <Plug>(vimfiler_execute)

    nmap <buffer> x <Plug>(vimfiler_execute_file)
    nmap <buffer> h <Plug>(vimfiler_move_to_up_directory)
    nmap <buffer> L <Plug>(vimfiler_move_to_drive)
    nmap <buffer> ~ <Plug>(vimfiler_move_to_home_directory)
    nmap <buffer> \ <Plug>(vimfiler_move_to_root_directory)
    nmap <buffer> V <Plug>(vimfiler_execute_new_gvim)
    nmap <buffer> . <Plug>(vimfiler_toggle_visible_dot_files)
    nmap <buffer> H <Plug>(vimfiler_popup_shell)
    nmap <buffer> e <Plug>(vimfiler_edit_file)
    nmap <buffer> E <Plug>(vimfiler_execute_external_filer)
    nmap <buffer> t <Plug>(vimfiler_execute_external_command)
    nmap <buffer> gf <Plug>(vimfiler_split_create)
    nmap <buffer> q <Plug>(vimfiler_hide)
    nmap <buffer> ? <Plug>(vimfiler_help)
    nmap <buffer> p <Plug>(vimfiler_preview_file)
    nmap <buffer> d <Plug>(vimfiler_delete)
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
function! vimfiler#create_filer(split_flag, directory)"{{{
  let l:bufname = '[1]vimfiler'
  let l:cnt = 2
  while buflisted(l:bufname)
    let l:bufname = printf('[%d]vimfiler', l:cnt)
    let l:cnt += 1
  endwhile

  if a:split_flag
    vsplit `=l:bufname`
  else
    edit `=l:bufname`
  endif

  call vimfiler#default_settings()
  setfiletype vimfiler

  let b:vimfiler = {}

  " Set current directory.
  let l:current = (a:directory != '')? a:directory : getcwd()
  lcd `=l:current`
  let b:vimfiler.current_dir = l:current
  if b:vimfiler.current_dir =~ '/$'
    let b:vimfiler.current_dir = b:vimfiler.current_dir[: -2]
  endif
  let b:vimfiler.is_visible_dot_files = 0
  let b:vimfiler.directory_cursor_pos = {}
  " Set mask.
  let b:vimfiler.current_mask = '/*'

  call vimfiler#force_redraw_screen()
  if a:split_flag
    call vimfiler#redraw_all_vimfiler()
  endif
endfunction"}}}
function! vimfiler#switch_filer(split_flag, directory)"{{{
  if &filetype == 'vimfiler'
    if winnr('$') != 1
      close
    else
      buffer #
    endif

    if a:directory != ''
      " Change current directory.
      let b:vimfiler.current_dir = a:directory
      if b:vimfiler.current_dir =~ '/$'
        let b:vimfiler.current_dir = b:vimfiler.current_dir[: -2]
      endif
    endif

    call vimfiler#force_redraw_screen()
    if a:split_flag
      call vimfiler#redraw_all_vimfiler()
    endif
    return
  endif

  " Search vimfiler window.
  let l:cnt = 1
  while l:cnt <= winnr('$')
    if getwinvar(l:cnt, '&filetype') == 'vimfiler'

      execute l:cnt . 'wincmd w'

      if a:directory != ''
        " Change current directory.
        let b:vimfiler.current_dir = a:directory
        if b:vimfiler.current_dir =~ '/$'
          let b:vimfiler.current_dir = b:vimfiler.current_dir[: -2]
        endif
      endif

      call vimfiler#force_redraw_screen()
      if a:split_flag
        call vimfiler#redraw_all_vimfiler()
      endif
      return
    endif

    let l:cnt += 1
  endwhile

  " Search vimfiler buffer.
  let l:cnt = 1
  while l:cnt <= bufnr('$')
    if getbufvar(l:cnt, '&filetype') == 'vimfiler'
      if a:split_flag
        execute 'sbuffer' . l:cnt
      else
        execute 'buffer' . l:cnt
      endif

      if a:directory != ''
        " Change current directory.
        let b:vimfiler.current_dir = a:directory
        if b:vimfiler.current_dir =~ '/$'
          let b:vimfiler.current_dir = b:vimfiler.current_dir[: -2]
        endif
      endif

      call vimfiler#force_redraw_screen()
      if a:split_flag
        call vimfiler#redraw_all_vimfiler()
      endif
      return
    endif

    let l:cnt += 1
  endwhile

  " Create window.
  call vimfiler#create_filer(a:split_flag, a:directory)
endfunction"}}}
function! vimfiler#force_redraw_screen()"{{{
  " Save current files.
  let l:current_files = split(glob(b:vimfiler.current_dir . b:vimfiler.current_mask), '\n')
  if b:vimfiler.is_visible_dot_files
    let l:current_files += filter(split(glob(b:vimfiler.current_dir . '/.*'), '\n'), 
          \'v:val !~ ''[/\\]\.\.\?$''')
  endif
  
  let b:vimfiler.current_files = []
  for l:file in l:current_files
    let l:filename = fnamemodify(l:file, ':t')

    if isdirectory(l:file)
      call add(b:vimfiler.current_files, {
            \ 'name' : l:filename, 
            \ 'extension' : '', 
            \ 'type' : '[DIR]', 
            \ 'size' : 0, 
            \ 'datemark' : '', 
            \ 'time' : 0, 
            \ 'is_directory' : 1, 
            \ 'is_marked' : 0, 
            \ })
    else
      call add(b:vimfiler.current_files, {
            \ 'name' : l:filename, 
            \ 'extension' : fnamemodify(l:filename, ':e'), 
            \ 'type' : vimfiler#get_filetype(l:file), 
            \ 'size' : getfsize(l:file), 
            \ 'datemark' : vimfiler#get_datemark(l:file), 
            \ 'time' : getftime(l:file), 
            \ 'is_directory' : 0, 
            \ 'is_marked' : 0, 
            \ })
    endif
  endfor

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
  call setline(1, 'Current directory: ' . b:vimfiler.current_dir . b:vimfiler.current_mask)

  " Append up directory.
  call append('$', '..')

  " Print files.
  let l:max_len = winwidth(winnr()) - 35
  if l:max_len > 50
    let l:max_len = 50
  endif
  for l:file in b:vimfiler.current_files
    let l:filename = l:file.name
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
    if l:file.is_directory
      call append('$', printf('%s  %s  [DIR] ',
            \ l:mark, l:filename
            \))
    else
      call append('$', printf('%s  %s  %s  %s  %s',
            \ l:mark, 
            \ l:filename, 
            \ l:file.type, 
            \ vimfiler#get_filesize(l:file.size), 
            \ l:file.datemark . strftime('%y/%m/%d %H:%M', l:file.time)
            \))
    endif
  endfor
  
  call setpos('.', l:pos)
  setlocal nomodifiable
endfunction"}}}
function! vimfiler#iswin()"{{{
  return has('win32') || has('win64')
endfunction"}}}
function! vimfiler#system(str, ...)"{{{
  return s:is_vimproc ? (a:0 == 0 ? vimproc#system(a:str) : vimproc#system(a:str, join(a:000)))
        \: (a:0 == 0 ? system(a:str) : system(a:str, join(a:000)))
endfunction"}}}
function! vimfiler#get_marked_files()"{{{
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
function! vimfiler#check_filename_line(line)"{{{
  return a:line == '..' || a:line =~ '^[*-]\s'
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
function! vimfiler#get_alternate_directory()"{{{
  let l:filetype = getbufvar(bufnr('#'), '&filetype')
  if l:filetype != 'vimfiler'
    return ''
  else
    return getbufvar(bufnr('#'), 'vimfiler').current_dir
  endif
endfunction"}}}
function! vimfiler#redraw_alternate_vimfiler()"{{{
  " Search vimfiler window.
  if getwinvar(winnr('#'), '&filetype') == 'vimfiler'

    execute winnr('#') . 'wincmd w'
    call vimfiler#redraw_screen()
    execute winnr('#') . 'wincmd w'
  endif
endfunction"}}}
function! vimfiler#redraw_all_vimfiler()"{{{
  let l:current_nr = winnr()
  let l:bufnr = 1
  while l:bufnr <= winnr('$')
    " Search vimfiler window.
    if getwinvar(l:bufnr, '&filetype') == 'vimfiler'

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
  if l:ext =~? 
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
  if a:size >= 1000000000
    " GB.
    return printf('%5.5sG', (a:size / 1000000000) . '.' .  (a:size % 1000000000))
  elseif a:size >= 1000000
    " MB.
    return printf('%5.5sM', (a:size / 1000000) . '.' . (a:size % 1000000))
  elseif a:size >= 1000
    " KB.
    return printf('%5.5sK', (a:size / 1000) . '.' . (a:size % 1000))
  else
    " B.
    return printf('%5.5sB', a:size)
  endif
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
"}}}

" Event functions.
function! s:event_bufwin_enter()"{{{
  if !exists('b:vimfiler')
    return
  endif

  lcd `=b:vimfiler.current_dir`
  call vimfiler#redraw_screen()
endfunction"}}}

" vim: foldmethod=marker

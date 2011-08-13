"=============================================================================
" FILE: vimfiler.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 13 Aug 2011.
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
" Version: 3.0, for Vim 7.0
"=============================================================================

" Check vimproc.
try
  call vimproc#version()
  let s:exists_vimproc = 1
catch
  let s:exists_vimproc = 0
endtry

let s:last_vimfiler_bufnr = -1
let s:last_system_is_vimproc = -1

" Global options definition."{{{
if !exists('g:vimfiler_execute_file_list')
  let g:vimfiler_execute_file_list = {}
endif
"}}}

augroup vimfiler"{{{
  autocmd!
augroup end"}}}

" User utility functions."{{{
function! vimfiler#default_settings()"{{{
  setlocal buftype=nofile
  setlocal noswapfile
  setlocal bufhidden=hide
  setlocal noreadonly
  setlocal nomodifiable
  setlocal nowrap
  setlocal nofoldenable
  setlocal foldcolumn=0
  setlocal nolist
  if has('netbeans_intg') || has('sun_workshop')
    setlocal noautochdir
  endif
  let &l:winwidth = g:vimfiler_min_filename_width + 10
  if has('conceal')
    setlocal conceallevel=3
    setlocal concealcursor=n
  endif

  " Set autocommands.
  augroup vimfiler"{{{
    autocmd WinEnter,BufWinEnter <buffer> call s:event_bufwin_enter()
    autocmd BufWinEnter <buffer> call s:restore_vimfiler()
    autocmd WinLeave,BufWinLeave <buffer> call s:event_bufwin_leave()
    autocmd BufReadCmd <buffer> call vimfiler#create_filer(expand('<amatch>'), ['overwrite'])
    autocmd VimResized <buffer> call vimfiler#redraw_all_vimfiler()
  augroup end"}}}

  call vimfiler#mappings#define_default_mappings()
endfunction"}}}
function! vimfiler#set_execute_file(exts, command)"{{{
  for ext in split(a:exts, ',')
    let g:vimfiler_execute_file_list[ext] = a:command
  endfor
endfunction"}}}
function! vimfiler#set_extensions(kind, exts)"{{{
  let g:vimfiler_extensions[a:kind] = {}
  for ext in split(a:exts, ',')
    let g:vimfiler_extensions[a:kind][ext] = 1
  endfor
endfunction"}}}
"}}}

" vimfiler plugin utility functions."{{{
function! vimfiler#create_filer(directory, options)"{{{
  if a:directory != '' && !isdirectory(a:directory)
    return
  endif

  " Check options.
  let l:split_flag = 0
  let l:overwrite_flag = 0
  let l:simple_flag = 0
  let l:double_flag = 0
  for l:option in a:options
    if l:option ==# 'split'
      let l:split_flag = 1
    elseif l:option ==# 'overwrite'
      let l:overwrite_flag = 1
    elseif l:option ==# 'simple'
      let l:simple_flag = 1
    elseif l:option ==# 'double'
      let l:double_flag = 1
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

  let b:vimfiler = {}

  " Set current directory.
  let l:current = (a:directory != '')? a:directory : getcwd()
  let l:current = vimfiler#util#substitute_path_separator(l:current)
  let b:vimfiler.current_dir = l:current
  if b:vimfiler.current_dir !~ '/$'
    let b:vimfiler.current_dir .= '/'
  endif

  let b:vimfiler.changed_dir = [b:vimfiler.current_dir]
  let b:vimfiler.current_changed_dir_index = -1
  let b:vimfiler.clipboard = {}
  let b:vimfiler.is_visible_dot_files = 0
  let b:vimfiler.is_simple = l:simple_flag
  let b:vimfiler.directory_cursor_pos = {}
  " Set mask.
  let b:vimfiler.current_mask = ''
  let b:vimfiler.sort_type = g:vimfiler_sort_type
  let b:vimfiler.is_safe_mode = g:vimfiler_safe_mode_by_default
  let b:vimfiler.another_vimfiler_bufnr = -1

  " Initialize schemes.
  call s:init_schemes()

  call vimfiler#default_settings()
  setfiletype vimfiler

  if l:double_flag
    " Create another vimfiler.
    call vimfiler#create_filer(b:vimfiler.current_dir,
          \ b:vimfiler.is_simple ? ['split', 'simple'] : ['split'])
    let s:last_vimfiler_bufnr = bufnr('%')
    let b:vimfiler.another_vimfiler_bufnr = bufnr('%')
    wincmd w
  endif

  call vimfiler#force_redraw_screen()
  3
endfunction"}}}
function! vimfiler#switch_filer(directory, options)"{{{
  if a:directory != '' && !isdirectory(a:directory)
    call vimfiler#print_error('Invalid directory name: ' . a:directory)
    return
  endif

  let l:split_flag = 0
  for l:option in a:options
    if l:option ==# 'split'
      let l:split_flag = 1
    endif
  endfor

  " Search vimfiler buffer.
  if buflisted(s:last_vimfiler_bufnr)
        \ && getbufvar(s:last_vimfiler_bufnr, '&filetype') ==# 'vimfiler'
        \ && (!exists('t:unite_buffer_dictionary') || has_key(t:unite_buffer_dictionary, s:last_vimfiler_bufnr))
    call s:switch_vimfiler(s:last_vimfiler_bufnr, l:split_flag, a:directory)
    return
  endif

  " Search vimfiler buffer.
  let l:cnt = 1
  while l:cnt <= bufnr('$')
    if getbufvar(l:cnt, '&filetype') ==# 'vimfiler'
        \ && (!exists('t:unite_buffer_dictionary') || has_key(t:unite_buffer_dictionary, l:cnt))
      call s:switch_vimfiler(l:cnt, l:split_flag, a:directory)
      return
    endif

    let l:cnt += 1
  endwhile

  " Create window.
  call vimfiler#create_filer(a:directory, a:options)
endfunction"}}}
function! vimfiler#available_schemes(name)"{{{
  return get(s:schemes, a:name, {})
endfunction"}}}
function! vimfiler#force_redraw_screen()"{{{
  " Save current files.

  let l:scheme = vimfiler#available_schemes('file')
  let l:current_files = map(l:scheme.read(b:vimfiler.current_dir, b:vimfiler.is_visible_dot_files)[1],
        \ 'vimfiler#util#substitute_path_separator(v:val)')
  for l:mask in split(b:vimfiler.current_mask)
    let l:current_files = filter(l:current_files, 'fnamemodify(v:val, ":t") =~# ' . string(l:mask))
  endfor

  let l:dirs = []
  let l:files = []
  for l:file in l:current_files
    if isdirectory(l:file)
      call add(l:dirs, {
          \ 'name' : l:file,
          \ 'extension' : '',
          \ 'type' : vimfiler#get_filetype(l:file),
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

  call vimfiler#redraw_prompt()

  " Append up directory.
  call append('$', '..')

  " Print files.
  let l:is_simple = b:vimfiler.is_simple ||
        \ winwidth(winnr()) < g:vimfiler_min_filename_width * 2
  let l:max_len = l:is_simple ?
        \ g:vimfiler_min_filename_width : (winwidth(winnr()) - g:vimfiler_min_filename_width)
  if l:max_len > g:vimfiler_max_filename_width
    let l:max_len = g:vimfiler_max_filename_width
  endif
  let l:max_len -= 1
  for l:file in b:vimfiler.current_files
    let l:filename = fnamemodify(l:file.name, ':t')
    if l:file.is_directory
      let l:filename .= '/'
    endif
    let l:filename = vimfiler#util#truncate_smart(
          \ l:filename, l:max_len, l:max_len/3, '..')

    let l:mark = l:file.is_marked ? '*' : '-'
    if !l:is_simple
      if l:file.is_directory
        let l:line = printf('%s %s %s         %s',
              \ l:mark, l:filename,
              \ l:file.type,
              \ l:file.datemark . strftime(g:vimfiler_time_format, l:file.time)
              \)
      else
        let l:line = printf('%s %s %s %s %s',
              \ l:mark,
              \ l:filename,
              \ l:file.type,
              \ vimfiler#get_filesize(l:file.size),
              \ l:file.datemark . strftime(g:vimfiler_time_format, l:file.time)
              \)
      endif
    else
      let l:line = printf('%s %s %s', l:mark, l:filename, l:file.type)
    endif

    call append('$', l:line)
  endfor

  call setpos('.', l:pos)
  setlocal nomodifiable
endfunction"}}}
function! vimfiler#redraw_prompt()"{{{
  let l:modifiable_save = &l:modifiable
  setlocal modifiable
  call setline(1, printf('%s%s%s[%s%s]',
        \ (b:vimfiler.is_safe_mode ? '' : b:vimfiler.is_simple ? '*u* ' : '*unsafe* '),
        \ (b:vimfiler.is_simple ? 'CD: ' : 'Current directory: '),
        \ b:vimfiler.current_dir ,
        \ (b:vimfiler.is_visible_dot_files ? '.:' : ''),
        \ b:vimfiler.current_mask))
  let &l:modifiable = l:modifiable_save
endfunction"}}}
function! vimfiler#iswin()"{{{
  return has('win32') || has('win64')
endfunction"}}}
function! vimfiler#exists_vimproc()"{{{
  return s:exists_vimproc
endfunction"}}}
function! vimfiler#system(str, ...)"{{{
  let s:last_system_is_vimproc = vimfiler#exists_vimproc()

  let l:command = a:str
  let l:input = join(a:000)
  if &termencoding != '' && &termencoding != &encoding
    let l:command = iconv(l:command, &encoding, &termencoding)
    let l:input = iconv(l:input, &encoding, &termencoding)
  endif

  let l:output = vimfiler#exists_vimproc() ? (a:0 == 0 ? vimproc#system(l:command) : vimproc#system(l:command, l:input))
        \: (a:0 == 0 ? system(l:command) : system(l:command, l:input))
  if &termencoding != '' && &termencoding != &encoding
    let l:output = iconv(l:output, &termencoding, &encoding)
  endif
  return l:output
endfunction"}}}
function! vimfiler#force_system(str, ...)"{{{
  let s:last_system_is_vimproc = 0

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
function! vimfiler#get_system_error()"{{{
  if s:last_system_is_vimproc
    return vimproc#get_last_status()
  else
    return v:shell_error
  endif
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
  return a:line_num == 1? '' : getline(a:line_num) == '..'? '..' : b:vimfiler.current_files[a:line_num - 3].name
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
    call vimfiler#print_error('Invalid path.')
    echo a:message
    let l:dir = input('', '', 'dir')
  endwhile

  return l:dir
endfunction"}}}
function! vimfiler#input_yesno(message)"{{{
  let l:yesno = input(a:message . ' [yes/no] : ')
  while l:yesno !~? '^\%(y\%[es]\|n\%[o]\)$'
    redraw
    if l:yesno == ''
      echo 'Canceled.'
      break
    endif

    " Retry.
    call vimfiler#print_error('Invalid input.')
    let l:yesno = input(a:message . ' [yes/no] : ')
  endwhile

  return l:yesno =~? 'y\%[es]'
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
function! vimfiler#get_filetype(filename)"{{{
  let l:filename = a:filename
  let l:ext = tolower(fnamemodify(l:filename, ':e'))
  
  if (vimfiler#iswin() && fnamemodify(l:filename, ':e') ==? 'LNK') || getftype(l:filename) ==# 'link'
    return '[LNK]'
  elseif isdirectory(l:filename)
    return '[DIR]'
  elseif has_key(g:vimfiler_extensions.text, l:ext)
    " Text.
    return '[TXT]'
  elseif has_key(g:vimfiler_extensions.image, l:ext)
    " Image.
    return '[IMG]'
  elseif has_key(g:vimfiler_extensions.archive, l:ext)
    " Archive.
    return '[ARC]'
  elseif has_key(g:vimfiler_extensions.multimedia, l:ext)
    " Multimedia.
    return '[MUL]'
  elseif l:filename =~ '^\.' || has_key(g:vimfiler_extensions.system, l:ext)
    " System.
    return '[SYS]'
  elseif (!vimfiler#iswin() && executable(l:filename))
        \|| has_key(g:vimfiler_extensions.execute, l:ext)
    " Execute.
    return '[EXE]'
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
  return stridx(a:checkstr, a:headstr) == 0
endfunction"}}}
function! vimfiler#exists_another_vimfiler()"{{{
  let l:winnr = bufwinnr(b:vimfiler.another_vimfiler_bufnr)
  return l:winnr > 0 && getwinvar(l:winnr, '&filetype') ==# 'vimfiler'
endfunction"}}}
function! vimfiler#bufnr_another_vimfiler()"{{{
  return vimfiler#exists_another_vimfiler() ?
        \ s:last_vimfiler_bufnr : -1
endfunction"}}}
function! vimfiler#winnr_another_vimfiler()"{{{
  return vimfiler#exists_another_vimfiler() ?
        \ bufwinnr(b:vimfiler.another_vimfiler_bufnr) : -1
endfunction"}}}
function! vimfiler#get_another_vimfiler()"{{{
  return vimfiler#exists_another_vimfiler() ?
        \ getbufvar(b:vimfiler.another_vimfiler_bufnr, 'vimfiler') : ''
endfunction"}}}
function! vimfiler#resolve(filename)"{{{
  return ((vimfiler#iswin() && fnamemodify(a:filename, ':e') ==? 'LNK') || getftype(a:filename) ==# 'link') ?
        \ vimfiler#util#substitute_path_separator(resolve(a:filename)) : a:filename
endfunction"}}}
function! vimfiler#print_error(message)"{{{
  echohl WarningMsg | echo a:message | echohl None
endfunction"}}}
function! vimfiler#set_variables(variables)"{{{
  let l:variables_save = {}
  for [key, value] in items(a:variables)
    let l:save_value = exists(key) ? eval(key) : ''

    let l:variables_save[key] = l:save_value
    execute 'let' key '= value'
  endfor
  
  return l:variables_save
endfunction"}}}
function! vimfiler#restore_variables(variables_save)"{{{
  for [key, value] in items(a:variables_save)
    execute 'let' key '= value'
  endfor
endfunction"}}}
function! vimfiler#cd(directory)"{{{
  execute g:vimfiler_cd_command '`=a:directory`'
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
  if !exists('b:vimfiler')
    return
  endif

  if bufwinnr(s:last_vimfiler_bufnr) > 0
        \ && s:last_vimfiler_bufnr != bufnr('%')
    let b:vimfiler.another_vimfiler_bufnr = s:last_vimfiler_bufnr
  endif

  call vimfiler#redraw_screen()
endfunction"}}}
function! s:event_bufwin_leave()"{{{
  let s:last_vimfiler_bufnr = bufnr('%')
endfunction"}}}
function! s:restore_vimfiler()"{{{
  if !exists('b:vimfiler')
    return
  endif

  " Search other vimfiler window.
  let l:cnt = 1
  while l:cnt <= winnr('$')
    if l:cnt != winnr() && getwinvar(l:cnt, '&filetype') ==# 'vimfiler'
      return
    endif

    let l:cnt += 1
  endwhile

  " Restore another vimfiler.
  if bufwinnr(b:vimfiler.another_vimfiler_bufnr) < 0
        \ && buflisted(b:vimfiler.another_vimfiler_bufnr) > 0
    call s:switch_vimfiler(b:vimfiler.another_vimfiler_bufnr, 1, '')
    wincmd p
    call vimfiler#redraw_screen()
  endif
endfunction"}}}

function! s:init_schemes()"{{{
  " Initialize internal scheme table.
  let s:schemes= {}

  " Search autoload.
  for list in split(globpath(&runtimepath, 'autoload/vimfiler/schemes/*.vim'), '\n')
    let l:scheme = fnamemodify(list, ':t:r')
    if !has_key(s:schemes, l:scheme)
      let s:schemes[l:scheme] = call('vimfiler#schemes#'.l:scheme.'#define', [])
    endif
  endfor
endfunction"}}}
function! s:switch_vimfiler(bufnr, split_flag, directory)"{{{
  if a:split_flag
    execute 'vertical sbuffer' . a:bufnr
  else
    execute 'buffer' . a:bufnr
  endif

  " Set current directory.
  let l:current = (a:directory != '')? a:directory : getcwd()
  let l:current = vimfiler#util#substitute_path_separator(l:current)
  let b:vimfiler.current_dir = l:current
  if b:vimfiler.current_dir !~ '/$'
    let b:vimfiler.current_dir .= '/'
  endif

  call vimfiler#force_redraw_screen()
endfunction"}}}

" vim: foldmethod=marker

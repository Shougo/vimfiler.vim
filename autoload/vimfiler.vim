"=============================================================================
" FILE: vimfiler.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 02 Sep 2012.
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

if !exists('g:loaded_vimfiler')
  runtime! plugin/vimfiler.vim
endif

" Check unite.vim."{{{
try
  let s:exists_unite_version = unite#version()
catch
  echomsg 'Error occured while loading unite.vim.'
  echomsg 'Please install unite.vim Ver.3.0 or above.'
  finish
endtry
if s:exists_unite_version < 300
  echomsg 'Your unite.vim is too old.'
  echomsg 'Please install unite.vim Ver.3.0 or above.'
  finish
endif"}}}

" Variables"{{{
let s:current_vimfiler = {}

let s:min_padding_width = 2
let s:max_padding_width = 35
let s:vimfiler_current_histories = []

let s:vimfiler_options = [
      \ '-buffer-name=', '-no-quit', '-quit', '-toggle', '-create',
      \ '-simple', '-double', '-split', '-horizontal', '-direction=',
      \ '-winheight=', '-winwidth=', '-winminwidth=', '-auto-cd', '-explorer'
      \]

let s:V = vital#of('vimfiler')
let s:BM = s:V.import('Vim.Buffer.Manager')
let s:manager = s:BM.new()  " creates new manager
call s:manager.config('opener', 'silent edit')
call s:manager.config('range', 'current')
"}}}

augroup vimfiler"{{{
  autocmd!
augroup end"}}}

" User utility functions."{{{
function! vimfiler#default_settings()"{{{
  call s:buffer_default_settings()

  " Set autocommands.
  augroup vimfiler"{{{
    autocmd WinEnter,BufWinEnter <buffer>
          \ call s:event_bufwin_enter(expand('<abuf>'))
    autocmd WinLeave,BufWinLeave <buffer>
          \ call s:event_bufwin_leave(expand('<abuf>'))
    autocmd VimResized <buffer>
          \ call vimfiler#redraw_all_vimfiler()
  augroup end"}}}
endfunction"}}}
function! vimfiler#set_execute_file(exts, command)"{{{
  return vimfiler#util#set_dictionary_helper(g:vimfiler_execute_file_list,
        \ a:exts, a:command)
endfunction"}}}
function! vimfiler#set_extensions(kind, exts)"{{{
  let g:vimfiler_extensions[a:kind] = {}
  for ext in split(a:exts, '\s*,\s*')
    let g:vimfiler_extensions[a:kind][ext] = 1
  endfor
endfunction"}}}
function! vimfiler#do_action(action)"{{{
  return printf(":\<C-u>call vimfiler#mappings#do_action(%s)\<CR>",
        \             string(a:action))
endfunction"}}}
function! vimfiler#smart_cursor_map(directory_map, file_map)"{{{
  return vimfiler#mappings#smart_cursor_map(a:directory_map, a:file_map)
endfunction"}}}

"}}}

" vimfiler plugin utility functions."{{{
function! vimfiler#get_current_vimfiler()"{{{
  return exists('b:vimfiler') ? b:vimfiler : s:current_vimfiler
endfunction"}}}
function! vimfiler#set_current_vimfiler(vimfiler)"{{{
  let s:current_vimfiler = a:vimfiler
endfunction"}}}
function! vimfiler#get_context()"{{{
  return vimfiler#get_current_vimfiler().context
endfunction"}}}
function! vimfiler#set_context(context)"{{{
  let old_context = vimfiler#get_context()

  if exists('b:vimfiler')
    let b:vimfiler.context = a:context
  else
    let s:current_vimfiler.context = a:context
  endif

  return old_context
endfunction"}}}
function! vimfiler#get_options()"{{{
  return copy(s:vimfiler_options)
endfunction"}}}
function! vimfiler#start(path, ...)"{{{
  if vimfiler#util#is_cmdwin()
    call vimfiler#print_error(
          \ '[vimfiler] Command line buffer is detected!')
    call vimfiler#print_error(
          \ '[vimfiler] Please close command line buffer.')
    return
  endif

  let path = a:path
  if vimfiler#util#is_win_path(path)
    let path = vimfiler#util#substitute_path_separator(
          \ fnamemodify(vimfiler#util#expand(path), ':p'))
  endif

  let context = vimfiler#initialize_context(get(a:000, 0, {}))
  if &l:modified && !&l:hidden
    " Split automatically.
    let context.split = 1
  endif

  if context.toggle && !context.create
    if vimfiler#close(context.buffer_name)
      return
    endif
  endif

  if !context.create
    " Search vimfiler buffer.
    for bufnr in filter(insert(range(1, bufnr('$')), bufnr('%')),
          \ "bufloaded(v:val) &&
          \ getbufvar(v:val, '&filetype') ==# 'vimfiler'")
      let vimfiler = getbufvar(bufnr, 'vimfiler')
      if type(vimfiler) == type({})
            \ && vimfiler.context.profile_name ==# context.profile_name
            \ && (!exists('t:unite_buffer_dictionary')
            \      || has_key(t:unite_buffer_dictionary, bufnr))
        call vimfiler#_switch_vimfiler(bufnr, context, path)
        return
      endif

      unlet vimfiler
    endfor
  endif

  " Create window.
  call s:create_filer(path, context)
endfunction"}}}
function! s:create_filer(path, context)"{{{
  let path = a:path
  if path == ''
    " Use current directory.
    let path = vimfiler#util#substitute_path_separator(getcwd())
  endif

  if &l:modified && !&l:hidden
    " Split automatically.
    let a:context.split = 1
  endif

  " Create new buffer name.
  let prefix = vimfiler#util#is_windows() ?
        \ '[vimfiler] - ' : '*vimfiler* - '
  let prefix .= a:context.profile_name

  let postfix = s:get_postfix(prefix, 1)

  let bufname = prefix . postfix

  " Set buffer_name.
  let a:context.profile_name = a:context.buffer_name
  let a:context.buffer_name = bufname

  if a:context.split
    if a:context.horizontal || a:context.double
      execute a:context.direction 'new'
    else
      execute a:context.direction 'vnew'
    endif
  endif

  " Save swapfile option.
  let swapfile_save = &swapfile
  set noswapfile

  try
    let ret = s:manager.open(bufname)
    " silent edit `=bufname`
    setlocal noswapfile
  finally
    let &swapfile = swapfile_save
  endtry

  if !ret.loaded
    call vimshell#echo_error(
          \ '[vimfiler] Failed to open Buffer "'. bufname .'".')
    return
  endif

  let a:context.path = path
  " echomsg path

  call vimfiler#handler#_event_handler('BufReadCmd', a:context)

  call s:event_bufwin_enter(bufnr('%'))
endfunction"}}}
function! vimfiler#get_directory_files(directory, ...)"{{{
  " Save current files.

  let is_manualed = get(a:000, 0, 0)

  let context = {
        \ 'vimfiler__is_dummy' : 0,
        \ 'is_redraw' : is_manualed,
        \ }
  let path = a:directory
  if path !~ '^\a\w*:'
    let path = b:vimfiler.source . ':' . path
  endif
  let args = vimfiler#parse_path(path)
  let current_files = unite#get_vimfiler_candidates([args], context)

  for file in current_files
    " Initialize.
    let file.vimfiler__is_marked = 0
    let file.vimfiler__is_opened = 0
    let file.vimfiler__nest_level = 0
  endfor

  let dirs = filter(copy(current_files), 'v:val.vimfiler__is_directory')
  let files = filter(copy(current_files), '!v:val.vimfiler__is_directory')
  if g:vimfiler_directory_display_top
    let current_files = vimfiler#sort(dirs, b:vimfiler.local_sort_type)
          \+ vimfiler#sort(files, b:vimfiler.local_sort_type)
  else
    let current_files = vimfiler#sort(files + dirs, b:vimfiler.local_sort_type)
  endif

  return current_files
endfunction"}}}
function! vimfiler#force_redraw_screen(...)"{{{
  let is_manualed = get(a:000, 0, 0)

  let old_original_files = {}
  for file in filter(copy(b:vimfiler.original_files),
        \ 'v:val.vimfiler__is_directory && v:val.vimfiler__is_opened')
    let old_original_files[file.action__path] = 1
  endfor

  " Use matcher_glob.
  let b:vimfiler.original_files =
        \ vimfiler#get_directory_files(b:vimfiler.current_dir, is_manualed)
  let index = 0
  for file in copy(b:vimfiler.original_files)
    if file.vimfiler__is_directory
          \ && has_key(old_original_files, file.action__path)
      let children = vimfiler#mappings#expand_tree_rec(file, old_original_files)

      let b:vimfiler.original_files = b:vimfiler.original_files[: index]
            \ + children + b:vimfiler.original_files[index+1 :]
      let index += len(children)
    endif

    let index += 1
  endfor

  call vimfiler#redraw_screen()

  redraw
  echo ''
endfunction"}}}
function! vimfiler#redraw_screen()"{{{
  let is_switch = &filetype != 'vimfiler'
  if is_switch
    " Switch vimfiler.
    let vimfiler = vimfiler#get_current_vimfiler()

    let save_winnr = winnr()
    let winnr = bufwinnr(vimfiler.bufnr)
    if winnr < 0
      " Not vimfiler window.
      return
    endif

    execute winnr . 'wincmd w'
  endif

  if !has_key(b:vimfiler, 'original_files')
    return
  endif

  let b:vimfiler.current_files =
        \ unite#filters#matcher_vimfiler_mask#define().filter(
        \ copy(b:vimfiler.original_files),
        \ { 'input' : b:vimfiler.current_mask })
  if !b:vimfiler.is_visible_dot_files
    call filter(b:vimfiler.current_files,
          \  'v:val.vimfiler__filename !~ "^\\."')
  endif

  let b:vimfiler.winwidth = (winwidth(0)+1)/2*2

  setlocal modifiable
  let current_file = vimfiler#get_file()

  " Clean up the screen.
  % delete _

  call vimfiler#redraw_prompt()

  " Append up directory.
  call append('$', '..')

  " Print files.
  call append('$',
        \ vimfiler#get_print_lines(b:vimfiler.current_files))

  let index = index(b:vimfiler.current_files, current_file)
  if index > 0
    call cursor(vimfiler#get_line_number(index), 0)
  else
    call cursor(3, 0)
  endif

  setlocal nomodifiable

  if is_switch
    execute save_winnr . 'wincmd w'
  endif
endfunction"}}}
function! vimfiler#redraw_prompt()"{{{
  if &filetype !=# 'vimfiler'
    return
  endif

  let modifiable_save = &l:modifiable
  setlocal modifiable
  let mask = !b:vimfiler.is_visible_dot_files
        \ && b:vimfiler.current_mask == '' ?
        \ '' : '[' . (b:vimfiler.is_visible_dot_files ? '.:' : '')
        \       . b:vimfiler.current_mask . ']'

  let prefix = printf('%s[in]: %s',
        \ (b:vimfiler.is_safe_mode ? '' : '! '),
        \ (b:vimfiler.source ==# 'file' ? '' :
        \                 b:vimfiler.source.':'))

  let dir = b:vimfiler.current_dir
  if b:vimfiler.source ==# 'file'
    let home = vimfiler#util#substitute_path_separator(expand('~')).'/'
    if stridx(dir, home) >= 0
      let dir = '~/' . dir[len(home):]
    endif
  endif

  if vimfiler#util#strchars(prefix.dir) > winwidth(0)
    let dir = fnamemodify(substitute(dir, '/$', '', ''), ':t')
  endif

  if dir !~ '/$'
    let dir .= '/'
  endif

  call setline(1, prefix .  dir . mask)
  let &l:modifiable = modifiable_save
endfunction"}}}
function! vimfiler#get_marked_files()"{{{
  return vimfiler#util#sort_by(filter(copy(vimfiler#get_current_vimfiler().current_files),
        \ 'v:val.vimfiler__is_marked'), 'v:val.vimfiler__marked_time')
endfunction"}}}
function! vimfiler#get_marked_filenames()"{{{
  return map(vimfiler#get_marked_files(), 'v:val.action__path')
endfunction"}}}
function! vimfiler#get_escaped_marked_files()"{{{
  return map(vimfiler#get_marked_filenames(),
        \ '"\"" . v:val . "\""')
endfunction"}}}
function! vimfiler#get_filename(...)"{{{
  let line_num = get(a:000, 0, line('.'))
  return line_num == 1 ? '' :
   \ getline(line_num) == '..' ? '..' :
   \ b:vimfiler.current_files[vimfiler#get_file_index(line_num)].action__path
endfunction"}}}
function! vimfiler#get_file(...)"{{{
  let line_num = get(a:000, 0, line('.'))
  let vimfiler = vimfiler#get_current_vimfiler()
  let index = vimfiler#get_file_index(line_num)
  return index < 0 ? {} :
        \ get(vimfiler.current_files, index, {})
endfunction"}}}
function! vimfiler#get_file_directory(...)"{{{
  let line_num = get(a:000, 0, line('.'))

  let file = vimfiler#get_file(line_num)
  if empty(file)
    let directory = vimfiler#get_current_vimfiler().current_dir
  else
    let directory = file.action__directory

    if file.vimfiler__is_directory
          \ && !file.vimfiler__is_opened
      let directory = vimfiler#util#substitute_path_separator(
            \ fnamemodify(file.action__directory, ':h'))
    endif
  endif

  return directory
endfunction"}}}
function! vimfiler#get_file_index(line_num)"{{{
  return a:line_num - 3
endfunction"}}}
function! vimfiler#get_original_file_index(line_num)"{{{
  return index(b:vimfiler.original_files, vimfiler#get_file(a:line_num))
endfunction"}}}
function! vimfiler#get_line_number(index)"{{{
  return a:index + 3
endfunction"}}}
function! vimfiler#input_directory(message)"{{{
  echo a:message
  let dir = input('', '', 'dir')
  while !isdirectory(dir)
    redraw
    if dir == ''
      echo 'Canceled.'
      break
    endif

    " Retry.
    call vimfiler#print_error('Invalid path.')
    echo a:message
    let dir = input('', '', 'dir')
  endwhile

  return dir
endfunction"}}}
function! vimfiler#input_yesno(message)"{{{
  let yesno = input(a:message . ' [yes/no] : ')
  while yesno !~? '^\%(y\%[es]\|n\%[o]\)$'
    redraw
    if yesno == ''
      echo 'Canceled.'
      break
    endif

    " Retry.
    call vimfiler#print_error('Invalid input.')
    let yesno = input(a:message . ' [yes/no] : ')
  endwhile

  return yesno =~? 'y\%[es]'
endfunction"}}}
function! vimfiler#force_redraw_all_vimfiler(...)"{{{
  let is_manualed = get(a:000, 0, 0)

  let current_nr = winnr()
  let bufnr = 1
  while bufnr <= winnr('$')
    " Search vimfiler window.
    if getwinvar(bufnr, '&filetype') ==# 'vimfiler'

      execute bufnr . 'wincmd w'
      call vimfiler#force_redraw_screen(is_manualed)
    endif

    let bufnr += 1
  endwhile

  execute current_nr . 'wincmd w'
endfunction"}}}
function! vimfiler#redraw_all_vimfiler()"{{{
  let current_nr = winnr()
  let bufnr = 1
  while bufnr <= winnr('$')
    " Search vimfiler window.
    if getwinvar(bufnr, '&filetype') ==# 'vimfiler'

      execute bufnr . 'wincmd w'
      call vimfiler#redraw_screen()
    endif

    let bufnr += 1
  endwhile

  execute current_nr . 'wincmd w'
endfunction"}}}
function! vimfiler#get_filetype(file)"{{{
  let ext = tolower(a:file.vimfiler__extension)

  if (vimfiler#util#is_windows() && ext ==? 'LNK')
        \ || get(a:file, 'vimfiler__ftype', '') ==# 'link'
    " Symbolic link.
    return '[LNK]'
  elseif a:file.vimfiler__is_directory
    " Directory.
    return '[DIR]'
  elseif has_key(g:vimfiler_extensions.text, ext)
    " Text.
    return '[TXT]'
  elseif has_key(g:vimfiler_extensions.image, ext)
    " Image.
    return '[IMG]'
  elseif has_key(g:vimfiler_extensions.archive, ext)
    " Archive.
    return '[ARC]'
  elseif has_key(g:vimfiler_extensions.multimedia, ext)
    " Multimedia.
    return '[MUL]'
  elseif a:file.vimfiler__filename =~ '^\.'
        \ || has_key(g:vimfiler_extensions.system, ext)
    " System.
    return '[SYS]'
  elseif a:file.vimfiler__is_executable
    " Execute.
    return '[EXE]'
  else
    " Others filetype.
    return '     '
  endif
endfunction"}}}
function! vimfiler#get_datemark(file)"{{{
  if a:file.vimfiler__filetime !~ '^\d\+$'
    return '~'
  endif

  let time = localtime() - a:file.vimfiler__filetime
  if time < 86400
    " 60 * 60 * 24
    return '!'
  elseif time < 604800
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
  return bufnr('%') != b:vimfiler.another_vimfiler_bufnr
        \ && getbufvar(b:vimfiler.another_vimfiler_bufnr,
        \         '&filetype') ==# 'vimfiler'
        \ && bufloaded(b:vimfiler.another_vimfiler_bufnr) > 0
endfunction"}}}
function! vimfiler#winnr_another_vimfiler()"{{{
  return winnr() == bufwinnr(b:vimfiler.another_vimfiler_bufnr) ?
        \ -1 : bufwinnr(b:vimfiler.another_vimfiler_bufnr)
endfunction"}}}
function! vimfiler#get_another_vimfiler()"{{{
  return vimfiler#exists_another_vimfiler() ?
        \ getbufvar(b:vimfiler.another_vimfiler_bufnr, 'vimfiler') : ''
endfunction"}}}
function! vimfiler#resolve(filename)"{{{
  return ((vimfiler#util#is_windows() && fnamemodify(a:filename, ':e') ==? 'LNK') || getftype(a:filename) ==# 'link') ?
        \ vimfiler#util#substitute_path_separator(resolve(a:filename)) : a:filename
endfunction"}}}
function! vimfiler#print_error(message)"{{{
  echohl WarningMsg | echo a:message | echohl None
endfunction"}}}
function! vimfiler#set_variables(variables)"{{{
  let variables_save = {}
  for [key, value] in items(a:variables)
    let save_value = exists(key) ? eval(key) : ''

    let variables_save[key] = save_value
    execute 'let' key '= value'
  endfor

  return variables_save
endfunction"}}}
function! vimfiler#restore_variables(variables_save)"{{{
  for [key, value] in items(a:variables_save)
    execute 'let' key '= value'
  endfor
endfunction"}}}
function! vimfiler#parse_path(path)"{{{
  let path = a:path

  let source_name = matchstr(path, '^\h[^:]*\ze:')
  if (vimfiler#util#is_windows() && len(source_name) == 1)
        \ || source_name == ''
    " Default source.
    let source_name = 'file'
    let source_arg = path
    if vimfiler#util#is_win_path(source_arg)
      let source_arg = vimfiler#util#substitute_path_separator(
            \ fnamemodify(expand(source_arg), ':p'))
    endif
  else
    let source_arg = path[len(source_name)+1 :]
  endif

  let source_args = source_arg  == '' ? [] :
        \  map(split(source_arg, '\\\@<!:', 1),
        \      'substitute(v:val, ''\\\(.\)'', "\\1", "g")')

  return insert(source_args, source_name)
endfunction"}}}
function! vimfiler#initialize_context(context)"{{{
  let default_context = {
    \ 'buffer_name' : 'default',
    \ 'no_quit' : 0,
    \ 'quit' : 0,
    \ 'toggle' : 0,
    \ 'create' : 0,
    \ 'simple' : 0,
    \ 'double' : 0,
    \ 'split' : 0,
    \ 'horizontal' : 0,
    \ 'winheight' : 0,
    \ 'winwidth' : 0,
    \ 'winminwidth' : 0,
    \ 'direction' : g:vimfiler_split_rule,
    \ 'auto_cd' : g:vimfiler_enable_auto_cd,
    \ 'explorer' : 0,
    \ 'vimfiler__prev_bufnr' : bufnr('%'),
    \ 'vimfiler__prev_winnr' : winbufnr('%'),
    \ }
  if get(a:context, 'explorer', 0)
    " Change default value.
    let default_context.buffer_name = 'explorer'
    let default_context.split = 1
    let default_context.toggle = 1
    let default_context.no_quit = 1
    let default_context.winwidth = 35
  endif
  let context = extend(default_context, a:context)

  if !has_key(context, 'profile_name')
    let context.profile_name = context.buffer_name
  endif

  return context
endfunction"}}}
function! vimfiler#get_histories()"{{{
  return copy(s:vimfiler_current_histories)
endfunction"}}}
function! vimfiler#set_histories(histories)"{{{
  let s:vimfiler_current_histories = a:histories
endfunction"}}}
function! vimfiler#get_print_lines(files)"{{{
  let is_simple = b:vimfiler.context.simple
  if s:max_padding_width + g:vimfiler_min_filename_width > winwidth(0)
    " Force simple.
    let is_simple = 1
  endif
  let max_len = winwidth(0) -
        \ (is_simple ? s:min_padding_width : s:max_padding_width)
  if max_len > g:vimfiler_max_filename_width
    let max_len = g:vimfiler_max_filename_width
  elseif max_len < s:min_padding_width
    let max_len = s:min_padding_width
  endif

  " Print files.
  let lines = []
  for file in a:files
    let filename = file.vimfiler__abbr
    if file.vimfiler__is_directory
          \ && filename !~ '/$'
      let filename .= '/'
    endif

    let mark = ''
    if file.vimfiler__nest_level > 0
      let mark .= repeat(' ', file.vimfiler__nest_level - 1)
            \ . g:vimfiler_tree_leaf_icon
    endif
    let mark .= file.vimfiler__is_marked ? g:vimfiler_marked_file_icon :
          \ !file.vimfiler__is_directory ?
          \     (!get(file, 'vimfiler__is_writable', 1) ?
          \      g:vimfiler_readonly_file_icon : g:vimfiler_file_icon) :
          \ file.vimfiler__is_opened ? g:vimfiler_tree_opened_icon :
          \                            g:vimfiler_tree_closed_icon
    let mark .= ' '
    let filename = vimfiler#util#truncate_smart(
          \ mark . filename, max_len, max_len/3, '..')
    if is_simple
      let line = substitute(
            \ filename . s:convert_filetype(file.vimfiler__filetype),
            \   '\s\+$', '', '')
    else
      let line = printf('%s %s %s %s',
            \ filename,
            \ file.vimfiler__filetype,
            \ s:get_filesize(file), s:get_filetime(file),
            \)
    endif

    call add(lines, line)
  endfor

  return lines
endfunction"}}}
function! vimfiler#close(buffer_name)"{{{
  let buffer_name = a:buffer_name
  if buffer_name !~ '@\d\+$'
    " Add postfix.
    let prefix = vimfiler#util#is_windows() ?
          \ '[vimfiler] - ' : '*vimfiler* - '
    let prefix .= buffer_name
    let buffer_name = prefix . s:get_postfix(prefix, 0)
  endif

  " Note: must escape file-pattern.
  let buffer_name =
        \ vimfiler#util#escape_file_searching(buffer_name)

  let quit_winnr = bufwinnr(buffer_name)
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
"}}}

" Sort.
function! vimfiler#sort(files, type)"{{{
  if a:type =~? '^n\%[one]$'
    " Ignore.
    let files = a:files
  elseif a:type =~? '^s\%[ize]$'
    let files = sort(a:files, 's:compare_size')
  elseif a:type =~? '^e\%[xtension]$'
    let files = sort(a:files, 's:compare_extension')
  elseif a:type =~? '^f\%[ilename]$'
    let files = sort(a:files, 's:compare_name')
  elseif a:type =~? '^t\%[ime]$'
    let files = sort(a:files, 's:compare_time')
  elseif a:type =~? '^m\%[anual]$'
    " Not implemented.
    let files = a:files
  else
    throw 'Invalid sort type.'
  endif

  if a:type =~ '^\u'
    " Reverse order.
    let files = reverse(files)
  endif

  return files
endfunction"}}}
function! s:compare_size(a, b)"{{{
  let not_over_a = a:a.vimfiler__filesize >= 0
  let not_over_b = a:b.vimfiler__filesize >= 0
  if not_over_a && not_over_b
    return (a:a.vimfiler__filesize - a:b.vimfiler__filesize)
  elseif not_over_a && !not_over_b
    return -1
  elseif !not_over_a && not_over_b
    return 1
  else
    return s:compare_filesize_pattern(a:a, a:b)
  endif
endfunction"}}}
function! s:compare_extension(i1, i2)"{{{
  return a:i1.vimfiler__extension > a:i2.vimfiler__extension ?
        \ -1 : a:i1.vimfiler__extension == a:i2.vimfiler__extension ? 0 : 1
endfunction"}}}
function! s:compare_name(i1, i2)"{{{
  return a:i1.vimfiler__filename ># a:i2.vimfiler__filename ?
        \ 1 : a:i1.vimfiler__filename == a:i2.vimfiler__filename ? 0 : -1
endfunction"}}}
function! s:compare_time(i1, i2)"{{{
  return a:i1.vimfiler__filetime - a:i2.vimfiler__filetime
endfunction"}}}
function! s:compare_filesize_pattern(a, b)"{{{
  let pattern_a = s:get_filesize(a:a)
  let pattern_b = s:get_filesize(a:b)
  return pattern_a ># pattern_b ?
        \ 1 : pattern_a == pattern_b ? 0 : -1
endfunction"}}}

" Complete.
function! vimfiler#complete(arglead, cmdline, cursorpos)"{{{
  let ret = vimfiler#parse_path(join(split(a:cmdline)[1:]))
  let source_name = ret[0]
  let source_args = ret[1:]

  let _ = []

  " Option names completion.
  let _ +=  filter(vimfiler#get_options(),
        \ 'stridx(v:val, a:arglead) == 0')

  " Source path completion.
  let _ += vimfiler#complete_path(a:arglead,
        \ join(split(a:cmdline)[1:]), a:cursorpos)

  let args = split(join(split(a:cmdline)[1:]), '\\\@<!\s\+')
  if !empty(args) && args[-1] !=# a:arglead
    call map(_, "v:val[len(args[-1])-len(a:arglead) :]")
  endif

  return sort(_)
endfunction"}}}
function! vimfiler#complete_path(arglead, cmdline, cursorpos)"{{{
  let ret = vimfiler#parse_path(a:cmdline)
  let source_name = ret[0]
  let source_args = ret[1:]

  let _ = []

  " Source args completion.
  let _ += unite#vimfiler_complete(
        \ [insert(copy(source_args), source_name)],
        \ join(source_args, ':'), a:cmdline, a:cursorpos)

  if a:arglead !~ ':'
    " Source name completion.
    let _ += map(filter(unite#get_vimfiler_source_names(),
          \ 'stridx(v:val, a:arglead) == 0'), 'v:val.":"')
  else
    " Add "{source-name}:".
    let _  = map(_, 'source_name.":".v:val')
  endif

  let args = split(join(split(a:cmdline)[1:]), '\\\@<!\s\+')
  if !empty(args) && args[-1] !=# a:arglead
    call map(_, "v:val[len(args[-1])-len(a:arglead) :]")
  endif

  return sort(_)
endfunction"}}}

" Event functions.
function! s:buffer_default_settings()"{{{
  setlocal buftype=nofile
  setlocal noswapfile
  setlocal noreadonly
  setlocal nowrap
  setlocal bufhidden=hide
  setlocal nolist
  setlocal foldcolumn=0
  setlocal nofoldenable
  setlocal nowrap
  setlocal nomodifiable
  setlocal nomodified
  if has('netbeans_intg') || has('sun_workshop')
    setlocal noautochdir
  endif
  if exists('&colorcolumn')
    setlocal colorcolumn=
  endif

  if has('conceal')
    setlocal conceallevel=3
    setlocal concealcursor=n
  endif
endfunction"}}}
function! s:event_bufwin_enter(bufnr)"{{{
  if &filetype ==# 'vimfiler'
    call s:buffer_default_settings()
  endif

  let vimfiler = getbufvar(a:bufnr, 'vimfiler')
  if type(vimfiler) != type({})
        \ || bufwinnr(a:bufnr) < 1
        \ || count(map(range(1, winnr('$')),
        \       'winbufnr(v:val)'), a:bufnr) > 1
    return
  endif

  if bufwinnr(a:bufnr) != winnr()
    let winnr = winnr()
    execute bufwinnr(a:bufnr) 'wincmd w'
  endif

  if !exists('b:vimfiler')
    return
  endif

  call vimfiler#set_current_vimfiler(vimfiler)

  let vimfiler = vimfiler#get_current_vimfiler()
  if !has_key(vimfiler, 'context')
    return
  endif

  let context = vimfiler#get_context()
  if context.winwidth != 0
    execute 'vertical resize' context.winwidth

    if context.split
      setlocal winfixwidth
    endif
  elseif context.winheight != 0
    execute 'resize' context.winheight
    if line('.') < winheight(0)
      normal! zb
    endif

    if context.split
      setlocal winfixheight
    endif
  endif

  let winwidth = (winwidth(0)+1)/2*2
  if vimfiler.winwidth != winwidth
    call vimfiler#redraw_screen()
  endif

  if exists('winnr')
    execute winnr.'wincmd w'
  endif
endfunction"}}}
function! s:event_bufwin_leave(bufnr)"{{{
  if !exists('b:vimfiler')
    return
  endif
endfunction"}}}

function! vimfiler#_switch_vimfiler(bufnr, context, directory)"{{{
  let context = vimfiler#initialize_context(a:context)

  if context.split
    if context.horizontal || context.double
      execute context.direction 'new'
    else
      execute context.direction 'vnew'
    endif
  endif

  execute 'buffer' . a:bufnr
  call s:event_bufwin_enter(a:bufnr)

  " Set current directory.
  if a:directory != ''
    let directory = vimfiler#util#substitute_path_separator(
          \ a:directory)
    if directory =~ ':'
      " Parse path.
      let ret = vimfiler#parse_path(directory)
      let b:vimfiler.source = ret[0]
      let directory = join(ret[1:], ':')
    endif

    let b:vimfiler.current_dir = directory
    if b:vimfiler.current_dir !~ '/$'
      let b:vimfiler.current_dir .= '/'
    endif
  endif

  let b:vimfiler.context = extend(b:vimfiler.context, context)
  call vimfiler#set_current_vimfiler(b:vimfiler)

  if a:context.double
    " Create another vimfiler.
    call vimfiler#mappings#create_another_vimfiler()
    wincmd p
  endif

  call vimfiler#force_redraw_all_vimfiler()
endfunction"}}}

function! s:get_postfix(prefix, is_create)"{{{
  let buffers = get(a:000, 0, range(1, bufnr('$')))
  let buflist = vimfiler#util#sort_by(filter(map(buffers,
        \ 'bufname(v:val)'), 'stridx(v:val, a:prefix) >= 0'),
        \ "str2nr(matchstr(v:val, '\\d\\+$'))")
  if empty(buflist)
    return ''
  endif

  let num = matchstr(buflist[-1], '@\zs\d\+$')
  return num == '' && !a:is_create ? '' :
        \ '@' . (a:is_create ? (num + 1) : num)
endfunction"}}}
function! s:get_filesize(file)"{{{
  if a:file.vimfiler__is_directory
    return '       '
  endif

  " Get human file size.
  let filesize = a:file.vimfiler__filesize
  if filesize < 0
    if a:file.action__path !~ '^\a\w\+:' &&
          \ has('python') && getftype(a:file.action__path) !=# 'link'
      let pattern = s:get_file_pattern(a:file.action__path)
    elseif filesize == -2
      " Above 2GB?
      let pattern = '>2.0'
    else
      let pattern = ''
    endif
    let suffix = (pattern != '') ? 'G' : ''
  elseif filesize >= 1000000000
    " GB.
    let suffix = 'G'
    let mega = filesize / 1024 / 1024
    let float = (mega%1024)*100/1024
    let pattern = printf('%3d.%02d', mega/1024, float)
  elseif filesize >= 1000000
    " MB.
    let suffix = 'M'
    let kilo = filesize / 1024
    let float = (kilo%1024)*100/1024
    let pattern = printf('%3d.%02d', kilo/1024, float)
  elseif filesize >= 1000
    " KB.
    let suffix = 'K'
    let float = (filesize%1024)*100/1024
    let pattern = printf('%3d.%02d', filesize/1024, float)
  else
    " B.
    let suffix = 'B'
    let float = ''
    let pattern = printf('%6d', filesize)
  endif

  return printf('%s%s', pattern, suffix)
endfunction"}}}
function! s:get_file_pattern(filename)"{{{
    " Use python.
python <<END
import os.path
import vim
filesize = os.path.getsize(vim.eval('a:filename'))
if filesize < 0:
  pattern = ''
else:
  mega = filesize / 1024 / 1024
  float = int((mega%1024)*100/1024)
  pattern = '%3d.%02d' % (mega/1024, float)

vim.command("let pattern = '%s'" % pattern)
END

  return pattern
endfunction"}}}
function! s:get_filetime(file)"{{{
  return (a:file.vimfiler__filetime =~ '^-\?\d\+$' ?
        \  (a:file.vimfiler__filetime <= 0 ? '' :
        \    a:file.vimfiler__datemark .
        \    strftime(g:vimfiler_time_format, a:file.vimfiler__filetime))
        \ : a:file.vimfiler__datemark . a:file.vimfiler__filetime)
endfunction"}}}
function! s:convert_filetype(filetype)"{{{
  return ' ' . get({'[TXT]' : '~', '[IMG]' : '!',
        \ '[ARC]' : '@', '[EXE]' : '#', '[MUL]' : '$', '[DIR]' : '%',
        \ '[SYS]' : '^', '[LNK]' : '&',}, a:filetype, '')
endfunction"}}}

" Global options definition."{{{
let g:vimfiler_execute_file_list =
      \ get(g:, 'vimfiler_execute_file_list', {})
let g:vimfiler_extensions =
      \ get(g:, 'vimfiler_extensions', {})
if !has_key(g:vimfiler_extensions, 'text')
  call vimfiler#set_extensions('text',
        \ 'txt,cfg,ini')
endif
if !has_key(g:vimfiler_extensions, 'image')
  call vimfiler#set_extensions('image',
        \ 'bmp,png,gif,jpg,jpeg,jp2,tif,ico,wdp,cur,ani')
endif
if !has_key(g:vimfiler_extensions, 'archive')
  call vimfiler#set_extensions('archive',
        \ 'lzh,zip,gz,bz2,cab,rar,7z,tgz,tar')
endif
if !has_key(g:vimfiler_extensions, 'system')
  call vimfiler#set_extensions('system',
        \ 'inf,sys,reg,dat,spi,a,so,lib,dll')
endif
if !has_key(g:vimfiler_extensions, 'multimedia')
  call vimfiler#set_extensions('multimedia',
        \ 'avi,asf,wmv,mpg,flv,swf,divx,mov,mpa,m1a,'.
        \ 'm2p,m2a,mpeg,m1v,m2v,mp2v,mp4,qt,ra,rm,ram,'.
        \ 'rmvb,rpm,smi,mkv,mid,wav,mp3,ogg,wma,au'
        \ )
endif
"}}}

" vim: foldmethod=marker

"=============================================================================
" FILE: vimfiler.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 02 Feb 2013.
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

" Check unite.vim. "{{{
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

" Variables "{{{
let s:current_vimfiler = {}

let s:vimfiler_current_histories = []

let s:vimfiler_options = [
      \ '-buffer-name=', '-no-quit', '-quit', '-toggle', '-create',
      \ '-simple', '-double', '-split', '-horizontal', '-direction=',
      \ '-winheight=', '-winwidth=', '-winminwidth=', '-auto-cd', '-explorer',
      \ '-reverse', '-project',
      \]
"}}}

" User utility functions. "{{{
function! vimfiler#default_settings() "{{{
  return vimfiler#init#_default_settings()
endfunction"}}}
function! vimfiler#set_execute_file(exts, command) "{{{
  return vimfiler#util#set_dictionary_helper(g:vimfiler_execute_file_list,
        \ a:exts, a:command)
endfunction"}}}
function! vimfiler#set_extensions(kind, exts) "{{{
  let g:vimfiler_extensions[a:kind] = {}
  for ext in split(a:exts, '\s*,\s*')
    let g:vimfiler_extensions[a:kind][ext] = 1
  endfor
endfunction"}}}
function! vimfiler#do_action(action) "{{{
  return printf(":\<C-u>call vimfiler#mappings#do_action(%s)\<CR>",
        \             string(a:action))
endfunction"}}}
function! vimfiler#smart_cursor_map(directory_map, file_map) "{{{
  return vimfiler#mappings#smart_cursor_map(a:directory_map, a:file_map)
endfunction"}}}
"}}}

" vimfiler plugin utility functions. "{{{
function! vimfiler#get_current_vimfiler() "{{{
  return exists('b:vimfiler') ? b:vimfiler : s:current_vimfiler
endfunction"}}}
function! vimfiler#set_current_vimfiler(vimfiler) "{{{
  let s:current_vimfiler = a:vimfiler
endfunction"}}}
function! vimfiler#get_context() "{{{
  return vimfiler#get_current_vimfiler().context
endfunction"}}}
function! vimfiler#set_context(context) "{{{
  let old_context = vimfiler#get_context()

  if exists('b:vimfiler')
    let b:vimfiler.context = a:context
  else
    let s:current_vimfiler.context = a:context
  endif

  return old_context
endfunction"}}}
function! vimfiler#get_options() "{{{
  return copy(s:vimfiler_options)
endfunction"}}}
function! vimfiler#start(path, ...) "{{{
  return call('vimfiler#init#_start', [a:path] + a:000)
endfunction"}}}
function! vimfiler#get_directory_files(directory, ...) "{{{
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
function! vimfiler#force_redraw_screen(...) "{{{
  return call('vimfiler#view#_force_redraw_screen', a:000)
endfunction"}}}
function! vimfiler#redraw_screen() "{{{
  return vimfiler#view#_redraw_screen()
endfunction"}}}
function! vimfiler#redraw_prompt() "{{{
  return vimfiler#view#_redraw_prompt()
endfunction"}}}
function! vimfiler#get_marked_files() "{{{
  return vimfiler#util#sort_by(filter(copy(vimfiler#get_current_vimfiler().current_files),
        \ 'v:val.vimfiler__is_marked'), 'v:val.vimfiler__marked_time')
endfunction"}}}
function! vimfiler#get_marked_filenames() "{{{
  return map(vimfiler#get_marked_files(), 'v:val.action__path')
endfunction"}}}
function! vimfiler#get_escaped_marked_files() "{{{
  return map(vimfiler#get_marked_filenames(),
        \ '"\"" . v:val . "\""')
endfunction"}}}
function! vimfiler#get_filename(...) "{{{
  let line_num = get(a:000, 0, line('.'))
  return line_num == 1 ? '' :
   \ getline(line_num) == '..' ? '..' :
   \ b:vimfiler.current_files[vimfiler#get_file_index(line_num)].action__path
endfunction"}}}
function! vimfiler#get_file(...) "{{{
  let line_num = get(a:000, 0, line('.'))
  let vimfiler = vimfiler#get_current_vimfiler()
  let index = vimfiler#get_file_index(line_num)
  return index < 0 ? {} :
        \ get(vimfiler.current_files, index, {})
endfunction"}}}
function! vimfiler#get_file_directory(...) "{{{
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
function! vimfiler#get_file_index(line_num) "{{{
  return a:line_num - vimfiler#get_file_offset()
endfunction"}}}
function! vimfiler#get_original_file_index(line_num) "{{{
  return index(b:vimfiler.original_files, vimfiler#get_file(a:line_num))
endfunction"}}}
function! vimfiler#get_line_number(index) "{{{
  return a:index + vimfiler#get_file_offset()
endfunction"}}}
function! vimfiler#get_file_offset() "{{{
  return vimfiler#get_context().explorer ?  2 : 3
endfunction"}}}
function! vimfiler#input_directory(message) "{{{
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
function! vimfiler#input_yesno(message) "{{{
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
function! vimfiler#force_redraw_all_vimfiler(...) "{{{
  return call('vimfiler#view#_force_redraw_all_vimfiler', a:000)
endfunction"}}}
function! vimfiler#redraw_all_vimfiler() "{{{
  return vimfiler#view#_redraw_all_vimfiler()
endfunction"}}}
function! vimfiler#get_datemark(file) "{{{
  return vimfiler#init#_get_datemark(a:file)
endfunction"}}}
function! vimfiler#get_filetype(file) "{{{
  return vimfiler#init#_get_filetype(a:file)
endfunction"}}}
function! vimfiler#head_match(checkstr, headstr) "{{{
  return stridx(a:checkstr, a:headstr) == 0
endfunction"}}}
function! vimfiler#exists_another_vimfiler() "{{{
  return bufnr('%') != b:vimfiler.another_vimfiler_bufnr
        \ && getbufvar(b:vimfiler.another_vimfiler_bufnr,
        \         '&filetype') ==# 'vimfiler'
        \ && bufloaded(b:vimfiler.another_vimfiler_bufnr) > 0
endfunction"}}}
function! vimfiler#winnr_another_vimfiler() "{{{
  return winnr() == bufwinnr(b:vimfiler.another_vimfiler_bufnr) ?
        \ -1 : bufwinnr(b:vimfiler.another_vimfiler_bufnr)
endfunction"}}}
function! vimfiler#get_another_vimfiler() "{{{
  return vimfiler#exists_another_vimfiler() ?
        \ getbufvar(b:vimfiler.another_vimfiler_bufnr, 'vimfiler') : ''
endfunction"}}}
function! vimfiler#resolve(filename) "{{{
  return ((vimfiler#util#is_windows() && fnamemodify(a:filename, ':e') ==? 'LNK') || getftype(a:filename) ==# 'link') ?
        \ vimfiler#util#substitute_path_separator(resolve(a:filename)) : a:filename
endfunction"}}}
function! vimfiler#print_error(message) "{{{
  echohl WarningMsg | echo a:message | echohl None
endfunction"}}}
function! vimfiler#set_variables(variables) "{{{
  let variables_save = {}
  for [key, value] in items(a:variables)
    let save_value = exists(key) ? eval(key) : ''

    let variables_save[key] = save_value
    execute 'let' key '= value'
  endfor

  return variables_save
endfunction"}}}
function! vimfiler#restore_variables(variables_save) "{{{
  for [key, value] in items(a:variables_save)
    execute 'let' key '= value'
  endfor
endfunction"}}}
function! vimfiler#parse_path(path) "{{{
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
function! vimfiler#initialize_context(context) "{{{
  return vimfiler#init#_initialize_context(a:context)
endfunction"}}}
function! vimfiler#get_histories() "{{{
  return copy(s:vimfiler_current_histories)
endfunction"}}}
function! vimfiler#set_histories(histories) "{{{
  let s:vimfiler_current_histories = a:histories
endfunction"}}}
function! vimfiler#close(buffer_name) "{{{
  let buffer_name = a:buffer_name
  if buffer_name !~ '@\d\+$'
    " Add postfix.
    let prefix = vimfiler#util#is_windows() ?
          \ '[vimfiler] - ' : '*vimfiler* - '
    let prefix .= buffer_name
    let buffer_name = prefix . vimfiler#init#_get_postfix(prefix, 0)
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
function! vimfiler#sort(files, type) "{{{
  if a:type =~? '^n\%[one]$'
    " Ignore.
    let files = a:files
  elseif a:type =~? '^s\%[ize]$'
    let files = vimfiler#util#sort_by(
          \ a:files, 'v:val.vimfiler__filesize')
  elseif a:type =~? '^e\%[xtension]$'
    let files = vimfiler#util#sort_by(
          \ a:files, 'v:val.vimfiler__extension')
  elseif a:type =~? '^f\%[ilename]$'
    let files = sort(a:files, 's:compare_filename')
  elseif a:type =~? '^t\%[ime]$'
    let files = vimfiler#util#sort_by(
          \ a:files, 'v:val.vimfiler__filetime')
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
" Compare filename by human order. "{{{
function! s:compare_filename(i1, i2)
  let words_1 = map(split(a:i1.vimfiler__filename, '\D\zs\ze\d'),
        \ "v:val =~ '^\\d' ? str2nr(v:val) : v:val")
  let words_2 = map(split(a:i2.vimfiler__filename, '\D\zs\ze\d'),
        \ "v:val =~ '^\\d' ? str2nr(v:val) : v:val")
  let words_1_len = len(words_1)
  let words_2_len = len(words_2)

  for i in range(0, min([words_1_len, words_2_len])-1)
    if words_1[i] ># words_2[i]
      return 1
    elseif words_1[i] <# words_2[i]
      return -1
    endif
  endfor

  return words_1_len - words_2_len
endfunction"}}}

" Complete.
function! vimfiler#complete(arglead, cmdline, cursorpos) "{{{
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
function! vimfiler#complete_path(arglead, cmdline, cursorpos) "{{{
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

" Global options definition. "{{{
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

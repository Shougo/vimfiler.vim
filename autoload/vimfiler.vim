"=============================================================================
" FILE: vimfiler.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 16 Mar 2013.
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
      \ '-reverse', '-project', '-columns=',
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
  return call('vimfiler#helper#_get_directory_files',
        \ [a:directory] + a:000)
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
  return filter(copy(vimfiler#get_current_vimfiler().current_files),
        \ 'v:val.vimfiler__is_marked')
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
  return call('vimfiler#helper#_get_file_directory', a:000)
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
  let offset = vimfiler#get_context().explorer ?  2 : 3
  return offset
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
function! vimfiler#print_error(message) "{{{
  echohl WarningMsg | echo a:message | echohl None
endfunction"}}}
function! vimfiler#parse_path(path) "{{{
  return vimfiler#helper#_parse_path(a:path)
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
function! vimfiler#complete(arglead, cmdline, cursorpos) "{{{
  return vimfiler#helper#_complete(a:arglead, a:cmdline, a:cursorpos)
endfunction"}}}
function! vimfiler#complete_path(arglead, cmdline, cursorpos) "{{{
  return vimfiler#helper#_complete_path(a:arglead, a:cmdline, a:cursorpos)
endfunction"}}}
"}}}

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
        \ 'rmvb,rpm,smi,mkv,mid,wav,mp3,ogg,wma,au,flac'
        \ )
endif
"}}}

" vim: foldmethod=marker

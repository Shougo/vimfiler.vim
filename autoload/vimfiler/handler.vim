"=============================================================================
" FILE: handler.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 17 Sep 2011.
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


function! vimfiler#handler#_event_handler(event_name, ...)  "{{{1
  let l:context = vimfiler#init_context(get(a:000, 0, {}))
  let l:path = get(l:context, 'path', expand('<afile>'))
  let [l:source_name, l:source_arg] = vimfiler#parse_path(l:path)

  return s:on_{a:event_name}(l:source_name, l:source_arg, l:context)
endfunction

" Event Handlers.

function! s:on_BufReadCmd(source_name, source_arg, context)  "{{{1
  " Check path.

  silent let l:ret = unite#vimfiler_check_filetype([[a:source_name, a:source_arg]])
  if empty(l:ret)
    " File not found.
    return
  endif
  let [l:type, l:info] = l:ret

  let b:vimfiler = {}
  let b:vimfiler.source = a:source_name
  if l:type ==# 'directory'
    call s:initialize_vimfiler_directory(l:info, a:context)
  elseif l:type ==# 'file'
    call s:initialize_vimfiler_file(a:source_arg, l:info[0], l:info[1])
  else
    call vimfiler#print_error('Unknown filetype.')
  endif
endfunction


function! s:on_BufWriteCmd(source_name, source_arg, context)  "{{{1
  " BufWriteCmd is published by :write or other commands with 1,$ range.
  return s:write(a:source_name, a:source_arg, 1, line('$'), 'BufWriteCmd')
endfunction


function! s:on_FileAppendCmd(source_name, source_arg, context)  "{{{1
  " FileAppendCmd is published by :write or other commands with >>.
  return s:write(a:source_name, a:source_arg, line("'["), line("']"), 'FileAppendCmd')
endfunction


function! s:on_FileWriteCmd(source_name, source_arg, context)  "{{{1
  " FileWriteCmd is published by :write or other commands with partial range
  " such as 1,2 where 2 < line('$').
  return s:write(a:source_name, a:source_arg, line("'["), line("']"), 'FileWriteCmd')
endfunction

function! s:write(source_name, source_arg, line1, line2, event_name)  "{{{1
  silent let l:ret = unite#vimfiler_check_filetype(
        \ [[a:source_name, a:source_arg]])
  if empty(l:ret)
    " File not found.
    return
  endif
  let [l:type, l:lines, l:dict] = l:ret

  if l:type !=# 'file'
    " Invalid filetype.
    call vimfiler#print_error('Invalid filetype: ' . l:source . l:source_arg)
    return
  endif

  try
    call unite#mappings#do_action('vimfiler__write', [l:dict], {
          \ 'vimfiler__line1' : a:line1,
          \ 'vimfiler__line2' : a:line2,
          \ 'vimfiler__eventname' : a:event_name,
          \ })
    if a:event_name ==# 'BufWriteCmd'
          \ && (a:source_name.':'.a:source_arg) ==# bufname('%')
      " Reset modified flag.
      setlocal nomodified
    endif
  catch
    call vimfiler#print_error(v:exception . ' ' . v:throwpoint)
  endtry
endfunction

function! s:initialize_vimfiler_directory(directory, context) "{{{1
  " Set current directory.
  let l:current = vimfiler#util#substitute_path_separator(a:directory)
  let b:vimfiler.current_dir = l:current
  if b:vimfiler.current_dir !~ '/$'
    let b:vimfiler.current_dir .= '/'
  endif

  let b:vimfiler.directories_history = []
  let b:vimfiler.is_visible_dot_files = 0
  let b:vimfiler.is_simple = a:context.is_simple
  let b:vimfiler.directory_cursor_pos = {}
  " Set mask.
  let b:vimfiler.current_mask = ''
  let b:vimfiler.sort_type = g:vimfiler_sort_type
  let b:vimfiler.is_safe_mode = g:vimfiler_safe_mode_by_default
  let b:vimfiler.another_vimfiler_bufnr = -1
  let b:vimfiler.winwidth = winwidth(0)

  call vimfiler#default_settings()
  set filetype=vimfiler

  if a:context.is_double
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
function! s:initialize_vimfiler_file(path, lines, dict) "{{{1
  " Set current directory.
  let b:vimfiler.current_path = a:path
  let b:vimfiler.current_file = a:dict

  " Clean up the screen.
  % delete _

  augroup vimfiler
    autocmd! * <buffer>
  augroup end

  call setline(1, a:lines)
  setlocal nomodified

  filetype detect
  setlocal buftype=acwrite
  setlocal noswapfile
endfunction"}}}

" vim: foldmethod=marker

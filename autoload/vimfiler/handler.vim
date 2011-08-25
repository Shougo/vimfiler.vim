"=============================================================================
" FILE: handler.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 26 Aug 2011.
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


function! vimfiler#handler#_event_handler(event_name)  "{{{1
  let l:path = expand('<afile>')
  let [l:source_name, l:source_arg] = vimfiler#parse_path(l:path)

  return s:on_{a:event_name}(l:source_name, l:source_arg)
endfunction

" Event Handlers.

function! s:on_BufWriteCmd(source_name, source_arg)  "{{{1
  " BufWriteCmd is published by :write or other commands with 1,$ range.
  return s:write(a:source_name, a:source_arg, 1, line('$'), 'BufWriteCmd')
endfunction


function! s:on_FileAppendCmd(source_name, source_arg)  "{{{1
  " FileAppendCmd is published by :write or other commands with >>.
  return s:write(a:source_name, a:source_arg, line("'["), line("']"), 'FileAppendCmd')
endfunction


function! s:on_FileWriteCmd(source_name, source_arg)  "{{{1
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

" vim: foldmethod=marker

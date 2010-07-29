"=============================================================================
" FILE: file.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 28 Jul 2010
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

" Global options definition."{{{
" External commands.
if !exists('g:vimfiler_external_delete_command')
  if vimfiler#iswin() && !executable('rm')
    let g:vimfiler_external_delete_command = 'system rmdir /Q /S $srcs'
  else
    let g:vimfiler_external_delete_command = 'rm -r $srcs'
  endif
endif
if !exists('g:vimfiler_external_copy_file_command')
  if vimfiler#iswin() && !executable('cp')
    let g:vimfiler_external_copy_file_command = 'system copy $src $dest'
  else
    let g:vimfiler_external_copy_file_command = 'cp $src $dest'
  endif
endif
if !exists('g:vimfiler_external_copy_directory_command')
  if vimfiler#iswin() && !executable('cp')
    " Can't support.
    let g:vimfiler_external_copy_directory_command = ''
  else
    let g:vimfiler_external_copy_directory_command = 'cp -r $src $dest'
  endif
endif
if !exists('g:vimfiler_external_move_command')
  if vimfiler#iswin() && !executable('mv')
    let g:vimfiler_external_move_command = 'move /Y $srcs $dest'
  else
    let g:vimfiler_external_move_command = 'mv $srcs $dest'
  endif
endif
"}}}

let s:scheme = {
      \ 'name' : 'file',
      \}

function! s:scheme.read(path, is_visible_dot_file)"{{{
  if isdirectory(a:path)
    let l:files = split(glob(a:path . '*'), '\n')
    if a:is_visible_dot_file
      let l:files += filter(split(glob(a:path . '.*'), '\n'), 'v:val !~ "[/\\\\]\.\.\\?$"')
    endif
    return [ 'directory', l:files ]
  elseif filereadable(a:path)
    return [ 'file', a:path ]
  else
    return []
  endif
endfunction"}}}
function! s:scheme.mv(dest_dir, src_files)"{{{
  let l:dest_drive = matchstr(a:dest_dir, '^\a\+\ze:')
  for l:src in a:src_files
    if isdirectory(l:src) && vimfiler#iswin() && matchstr(l:src, '^\a\+\ze:') !=? l:dest_drive
      " rename() doesn't supported directory over drive move in Windows.
      if g:vimfiler_external_copy_directory_command == ''
        echohl Error | echoerr "Directory move is not supported in this platform. Please install cp.exe." | echohl None
      else
        call s:external('copy_directory', a:dest_dir, [l:src])
        call s:external('delete', '', [l:src])
      endif
    else
      call rename(l:src, a:dest_dir . fnamemodify(l:src, ':t'))
    endif
  endfor
endfunction"}}}
function! s:scheme.cp(dest_dir, src_files)"{{{
  for l:file in a:src_files
    if isdirectory(l:file)
      if g:vimfiler_external_copy_directory_command == ''
        echohl Error | echoerr "Recursive copy is not supported in this platform. Please install cp.exe." | echohl None
      else
        call s:external('copy_directory', a:dest_dir, [l:file])
      endif
    else
      call s:external('copy_file', a:dest_dir, [l:file])
    endif
  endfor
endfunction"}}}
function! s:scheme.rm(files)"{{{
  for l:file in a:files
    if isdirectory(l:file)
      call s:external('delete', '', [l:file])
    else
      call delete(l:file)
    endif
  endfor
endfunction"}}}

function! vimfiler#schemes#file#define()"{{{
  return s:scheme
endfunction"}}}

function! s:external(command, dest_dir, src_files)"{{{
  let l:command_line = g:vimfiler_external_{a:command}_command

  if l:command_line =~# '\$src\>'
    for l:src in a:src_files
      let l:command_line = g:vimfiler_external_{a:command}_command
      
      let l:command_line = substitute(l:command_line, 
            \'\$src\>', '"'.l:src.'"', 'g') 
      let l:command_line = substitute(l:command_line, 
            \'\$dest\>', '"'.a:dest_dir.'"', 'g')
      
      if vimfiler#iswin() && l:command_line =~# '^system '
        let l:output = vimfiler#force_system(l:command_line[7:])
      else
        let l:output = vimfiler#system(l:command_line)
      endif
    endfor
  else
    let l:command_line = substitute(l:command_line, 
          \'\$srcs\>', join(map(a:src_files, '''"''.v:val.''"''')), 'g') 
    let l:command_line = substitute(l:command_line, 
          \'\$dest\>', '"'.a:dest_dir.'"', 'g')

    if vimfiler#iswin() && l:command_line =~# '^system '
      let l:output = vimfiler#force_system(l:command_line[7:])
    else
      let l:output = vimfiler#system(l:command_line)
    endif
    
    echon l:output
  endif
endfunction"}}}
" vim: foldmethod=marker

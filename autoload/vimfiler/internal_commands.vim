"=============================================================================
" FILE: internal_commands.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 29 Jul 2010
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

function! vimfiler#internal_commands#mv(dest_dir, src_files)"{{{
  let l:scheme = vimfiler#available_schemes('file')
  call l:scheme.mv(a:dest_dir, a:src_files)
endfunction"}}}
function! vimfiler#internal_commands#cp(dest_dir, src_files)"{{{
  let l:scheme = vimfiler#available_schemes('file')
  call l:scheme.cp(a:dest_dir, a:src_files)
endfunction"}}}
function! vimfiler#internal_commands#rm(files)"{{{
  let l:scheme = vimfiler#available_schemes('file')
  call l:scheme.rm(a:files)
endfunction"}}}

function! vimfiler#internal_commands#cd(dir, ...)"{{{
  let l:save_history = a:0 ? a:1 : 1

  if a:dir == '..'
    if b:vimfiler.current_dir =~ '^\a\+:[/\\]$\|^/$'
      " Ignore.
      return
    endif

    let l:dir = simplify(b:vimfiler.current_dir . '/' . a:dir)
  elseif a:dir == '/'
    " Root.
    let l:dir = vimfiler#iswin() ? 
          \matchstr(fnamemodify(b:vimfiler.current_dir, ':p'), '^\a\+:[/\\]') : a:dir
  elseif a:dir == '~'
    " Home.
    let l:dir = expand('~')
  elseif (vimfiler#iswin() && a:dir =~ '^\a\+:[/\\]\|^\a\+:$')
        \ || (!vimfiler#iswin() && a:dir =~ '^/')
    let l:dir = a:dir
  else
    " Relative path.
    let l:dir = substitute(simplify(b:vimfiler.current_dir . a:dir), '\\', '/', 'g')
  endif

  let l:dir = vimfiler#resolve(l:dir)

  if !isdirectory(l:dir)
    " Ignore.
    return
  endif
  
  lcd `=l:dir`
  if l:dir !~ '/$'
    let l:dir .= '/'
  endif

  " Save current pos.
  let l:save_pos = getpos('.')
  let b:vimfiler.directory_cursor_pos[b:vimfiler.current_dir] = 
        \ deepcopy(l:save_pos)
  let l:prev_dir = b:vimfiler.current_dir
  let b:vimfiler.current_dir = l:dir

  " Save changed directories.
  if l:save_history
    " Reset b:vimfiler.current_changed_dir_index.
    if b:vimfiler.current_changed_dir_index !=# -1
      call add(b:vimfiler.changed_dir, l:prev_dir)
      let b:vimfiler.current_changed_dir_index = -1
    endif

    call add(b:vimfiler.changed_dir, l:dir)

    let l:max_save = g:vimfiler_max_directory_histories > 0 ? g:vimfiler_max_directory_histories : 10
    if len(b:vimfiler.changed_dir) >= l:max_save
      " Get last l:max_save num elements.
      let b:vimfiler.changed_dir = b:vimfiler.changed_dir[-l:max_save :]
    endif
  endif
  
  " Redraw.
  call vimfiler#force_redraw_screen()

  " Restore cursor pos.
  let l:save_pos[1] = 3
  call setpos('.', (has_key(b:vimfiler.directory_cursor_pos, l:dir) ?
        \ b:vimfiler.directory_cursor_pos[l:dir] : l:save_pos))
endfunction"}}}
function! vimfiler#internal_commands#open(filename)"{{{
  if !exists('*vimproc#open')
    echoerr 'vimproc#open() is not found. Please install vimproc Ver.4.1 or later.'
    return
  endif

  call vimproc#open(a:filename)
endfunction"}}}
function! vimfiler#internal_commands#gexe(filename)"{{{
  if !exists('*vimproc#system_bg')
    echoerr 'vimproc#system_bg() is not found. Please install vimproc Ver.4.1 or later.'
    return
  endif

  call vimproc#system_bg(a:filename)
endfunction"}}}
function! vimfiler#internal_commands#split()"{{{
  if g:vimfiler_split_command ==# 'split_nicely'
    " Split nicely.
    if winheight(0) > &winheight
      split
    else
      vsplit
    endif
  else
    execute g:vimfiler_split_command
  endif
endfunction"}}}
function! vimfiler#internal_commands#edit(filename, ...)"{{{
  let l:edit_command = a:0 > 0 ? a:1 : g:vimfiler_edit_command
  
  if isdirectory(a:filename)
    call vimfiler#create_filer(a:filename, 
          \b:vimfiler.is_simple ? ['split', 'simple'] : ['split'])
    return
  endif
  
  try
    let l:vimfiler_save = b:vimfiler
    
    if l:edit_command ==# 'edit_nicely'
      if winheight(0) > &winheight
        new `=a:filename`
      else
        vnew `=a:filename`
      endif
    else
      execute l:edit_command a:filename
    endif

    let b:vimfiler = l:vimfiler_save
  catch
    echohl Error | echomsg v:errmsg | echohl None
  endtry
endfunction"}}}
function! vimfiler#internal_commands#pedit(filename)"{{{
  try
    let l:vimfiler_save = b:vimfiler
    
    execute g:vimfiler_pedit_command a:filename
    
    if g:vimfiler_pedit_command == 'pedit'
      wincmd p
      let b:vimfiler = l:vimfiler_save
    endif

    if g:vimfiler_pedit_command == 'pedit'
      wincmd p
    endif
  catch
    echohl Error | echomsg v:errmsg | echohl None
  endtry
endfunction"}}}

" vim: foldmethod=marker

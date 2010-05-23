"=============================================================================
" FILE: exrename.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 23 May 2010
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

function! vimfiler#exrename#create_buffer(files)"{{{
  let l:vimfiler_save = b:vimfiler
  let l:bufnr = bufnr('%')
  edit exrename
  setfiletype exrename
  setlocal buftype=acwrite
  let b:exrename = l:vimfiler_save
  let b:exrename.bufnr = l:bufnr
  let b:exrename.current_files = a:files

  nnoremap <buffer><silent> q    :<C-u>call <SID>exit()<CR>
  augroup exrename
    autocmd!
    autocmd BufWriteCmd <buffer> call s:do_rename()
  augroup END
  
  " Clean up the screen.
  % delete _
  
  " Print files.
  let l:max_len = winwidth(winnr()) - g:vimfiler_min_filename_width
  if l:max_len > g:vimfiler_max_filename_width
    let l:max_len = g:vimfiler_max_filename_width
  endif
  for l:file in a:files
    let l:filename = fnamemodify(l:file.name, ':t')
    if l:file.is_directory
      let l:filename .= '/'
    endif
    if len(l:filename) < l:max_len
      let l:filename .= repeat(' ', l:max_len - len(l:filename))
    endif

    if l:file.is_directory
      let l:line = printf('%s [DIR]         %s',
            \ l:filename, 
            \ l:file.datemark . strftime('%y/%m/%d %H:%M', l:file.time)
            \)
    else
      let l:line = printf('%s %s %s %s',
            \ l:filename, 
            \ l:file.type, 
            \ vimfiler#get_filesize(l:file.size), 
            \ l:file.datemark . strftime('%y/%m/%d %H:%M', l:file.time)
            \)
    endif

    call append('$', l:line)
  endfor

  1delete

  setlocal nomodified
endfunction"}}}
function! s:exit()"{{{
  let l:exrename_buf = bufnr('%')
  call s:custom_alternate_buffer()
  execute 'bdelete!' l:exrename_buf
endfunction"}}}
function! s:do_rename()"{{{
  if line('$') != len(b:exrename.current_files)
    echohl WarningMsg | echo 'Invalid rename buffer.' | echohl None
    return
  endif

  " Rename files.
  let l:linenr = 1
  let l:files = b:exrename.current_files
  while l:linenr <= line('$')
    call rename(l:files[l:linenr - 1].name, matchstr(getline(l:linenr), '^.*\ze\s\+\[\a\+\]'))
    
    let l:linenr += 1
  endwhile
  
  let l:exrename_buf = bufnr('%')
  execute 'buffer!' b:exrename.bufnr
  execute 'bdelete!' l:exrename_buf

  call vimfiler#force_redraw_all_vimfiler()
endfunction"}}}

function! s:custom_alternate_buffer()"{{{
  if bufnr('%') != bufnr('#') && buflisted(bufnr('#'))
    buffer! #
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
      bprevious!
    else
      bnext!
    endif
  endif
endfunction"}}}

" vim: foldmethod=marker

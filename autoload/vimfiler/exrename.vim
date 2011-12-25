"=============================================================================
" FILE: exrename.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 26 Dec 2011.
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
  let vimfiler_save = deepcopy(b:vimfiler)
  let bufnr = bufnr('%')

  vsplit
  edit exrename
  highlight clear
  syntax clear

  setlocal buftype=acwrite
  let b:exrename = vimfiler_save
  let b:exrename.bufnr = bufnr

  lcd `=b:exrename.current_dir`

  nnoremap <buffer><silent> q    :<C-u>call <SID>exit()<CR>
  augroup exrename
    autocmd!
    autocmd BufWriteCmd <buffer> call s:do_rename()
    autocmd CursorMoved,CursorMovedI <buffer> call s:check_lines()
  augroup END

  setfiletype exrename

  syntax match ExrenameModified '^.*$'
  highlight def link ExrenameModified Todo
  highlight def link ExrenameOriginal Normal

  " Clean up the screen.
  % delete _

  " Print files.
  let b:exrename.current_files = []
  let b:exrename.current_filenames = []
  for file in a:files
    let filename = file.vimfiler__filename
    if file.vimfiler__is_directory
      let filename .= '/'
    endif

    execute 'syntax match ExrenameOriginal'
          \ '/'.printf('^\%%%dl%s$', line('$'), escape(filename, '/')).'/'
    call append('$', filename)
    call add(b:exrename.current_files, file)
    call add(b:exrename.current_filenames, filename)
  endfor

  1delete

  setlocal nomodified
endfunction"}}}
function! s:exit()"{{{
  let exrename_buf = bufnr('%')
  " Switch buffer.
  if winnr('$') != 1
    close
  else
    call s:custom_alternate_buffer()
  endif
  execute 'bdelete!' exrename_buf
endfunction"}}}
function! s:do_rename()"{{{
  if line('$') != len(b:exrename.current_filenames)
    echohl Error | echo 'Invalid rename buffer!' | echohl None
    return
  endif

  " Rename files.
  let linenr = 1
  while linenr <= line('$')
    let filename = b:exrename.current_filenames[linenr - 1]
    if filename !=# getline(linenr)
      let file = b:exrename.current_files[linenr - 1]
      call unite#mappings#do_action('vimfiler__rename', [file],
            \ {'action__filename' : getline(linenr)})
    endif

    let linenr += 1
  endwhile

  setlocal nomodified
  call s:exit()

  call vimfiler#force_redraw_all_vimfiler()
endfunction"}}}

function! s:check_lines()"{{{
  if line('$') != len(b:exrename.current_filenames)
    echohl Error | echo 'Invalid rename buffer!' | echohl None
    return
  endif
endfunction"}}}

function! s:custom_alternate_buffer()"{{{
  if bufnr('%') != bufnr('#') && buflisted(bufnr('#'))
    buffer #
  else
    let cnt = 0
    let pos = 1
    let current = 0
    while pos <= bufnr('$')
      if buflisted(pos)
        if pos == bufnr('%')
          let current = cnt
        endif

        let cnt += 1
      endif

      let pos += 1
    endwhile

    if current > cnt / 2
      bprevious
    else
      bnext
    endif
  endif
endfunction"}}}

" vim: foldmethod=marker

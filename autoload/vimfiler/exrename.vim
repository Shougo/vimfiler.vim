"=============================================================================
" FILE: exrename.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
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

function! vimfiler#exrename#create_buffer(files) "{{{
  let vimfiler_save = deepcopy(b:vimfiler)
  let bufnr = bufnr('%')

  vsplit
  call vimfiler#redraw_screen()
  let prefix = vimfiler#util#is_windows() ?
        \ '[exrename] - ' : '*exrename* - '
  execute 'edit' fnameescape(prefix . b:vimfiler.context.buffer_name)

  setlocal buftype=acwrite
  setlocal noswapfile
  let b:exrename = vimfiler_save
  let b:exrename.bufnr = bufnr

  if b:exrename.source ==# 'file'
    " Initialize load.
    call unite#kinds#cdable#define()

    execute g:unite_kind_cdable_lcd_command
          \ fnameescape(b:exrename.current_dir)
  endif

  nnoremap <buffer><silent> q    :<C-u>call <SID>exit()<CR>
  augroup vimfiler-exrename
    autocmd! * <buffer>
    autocmd BufWriteCmd <buffer> call s:do_rename()
    autocmd CursorMoved,CursorMovedI <buffer> call s:check_lines()
  augroup END

  setfiletype exrename

  " Clean up the screen.
  silent % delete _

  silent! syntax clear exrenameOriginal

  " Print files.
  let b:exrename.current_files = []
  let b:exrename.current_filenames = []
  let cnt = 1
  for file in a:files
    let filename = file.action__path
    if stridx(filename, b:exrename.current_dir) == 0
      let filename = filename[len(b:exrename.current_dir) :]
    endif

    if file.vimfiler__is_directory
      let filename .= '/'
    endif

    execute 'syntax match exrenameOriginal'
          \ '/'.printf('^\%%%dl%s$', cnt,
          \ escape(vimfiler#util#escape_pattern(filename), '/')).'/'
    call add(b:exrename.current_files, file)
    call add(b:exrename.current_filenames, filename)

    let cnt += 1
  endfor

  call setline(1, b:exrename.current_filenames)

  setlocal nomodified
endfunction"}}}
function! s:exit() "{{{
  let exrename_buf = bufnr('%')
  " Switch buffer.
  if winnr('$') != 1
    close
  else
    call s:custom_alternate_buffer()
  endif
  silent execute 'bdelete!' exrename_buf

  call vimfiler#redraw_all_vimfiler()
endfunction"}}}
function! s:do_rename() "{{{
  if line('$') != len(b:exrename.current_filenames)
    echohl Error | echo 'Invalid rename buffer!' | echohl None
    return
  endif

  " Rename files.
  let linenr = 1
  let max = line('$')
  while linenr <= max
    let filename = b:exrename.current_filenames[linenr - 1]

    redraw
    echo printf('(%'.len(max).'d/%d): %s -> %s',
          \ linenr, max, filename, getline(linenr))

    if filename !=# getline(linenr)
      let file = b:exrename.current_files[linenr - 1]
      let new_file = vimfiler#util#expand(getline(linenr))
      if new_file !~ '^\%(\a\a\+:\)\|^\%(\a:\|/\)'
        " Add current_dir.
        let new_file = b:exrename.current_dir . new_file
      endif
      call unite#mappings#do_action('vimfiler__rename', [file], {
            \ 'vimfiler__current_directory' : b:exrename.current_dir,
            \ 'action__filename' : new_file,
            \ })
    endif

    let linenr += 1
  endwhile

  redraw
  echo 'Rename done!'

  setlocal nomodified
  call s:exit()

  call vimfiler#force_redraw_all_vimfiler()
endfunction"}}}

function! s:check_lines() "{{{
  if !exists('b:exrename')
    return
  endif

  if line('$') != len(b:exrename.current_filenames)
    echohl Error | echo 'Invalid rename buffer!' | echohl None
    return
  endif
endfunction"}}}

function! s:custom_alternate_buffer() "{{{
  if bufnr('%') != bufnr('#') && buflisted(bufnr('#'))
    buffer #
  endif

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
endfunction"}}}

" vim: foldmethod=marker

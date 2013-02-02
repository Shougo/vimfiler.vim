"=============================================================================
" FILE: view.vim
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

let s:save_cpo = &cpo
set cpo&vim

let s:min_padding_width = 2
let s:max_padding_width = 26

function! vimfiler#view#_force_redraw_screen(...) "{{{
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
      " Insert children.
      let children = vimfiler#mappings#expand_tree_rec(file, old_original_files)

      let b:vimfiler.original_files = b:vimfiler.original_files[: index]
            \ + children + b:vimfiler.original_files[index+1 :]
      let index += len(children)
    endif

    let index += 1
  endfor

  call vimfiler#view#_redraw_screen()

  redraw
  echo ''
endfunction"}}}
function! vimfiler#view#_redraw_screen() "{{{
  let is_switch = &filetype !=# 'vimfiler'
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

  let current_file = vimfiler#get_file()

  let b:vimfiler.current_files =
        \ unite#filters#matcher_vimfiler_mask#define().filter(
        \ copy(b:vimfiler.original_files),
        \ { 'input' : b:vimfiler.current_mask })
  if !b:vimfiler.is_visible_dot_files
    call filter(b:vimfiler.current_files,
          \  "v:val.vimfiler__filename !~ '^\\.'")

    let b:vimfiler.current_files =
          \ s:check_tree(b:vimfiler.current_files)
  endif

  let b:vimfiler.winwidth = (winwidth(0)+1)/2*2

  setlocal modifiable

  " Clean up the screen.
  % delete _

  call vimfiler#view#_redraw_prompt()

  if !vimfiler#get_context().explorer
    " Append up directory.
    call append('$', '..')
  endif

  " Print files.
  call append('$',
        \ vimfiler#view#_get_print_lines(b:vimfiler.current_files))

  let index = index(b:vimfiler.current_files, current_file)
  if index > 0
    call cursor(vimfiler#get_line_number(index), 0)
  else
    call cursor(vimfiler#get_file_offset(), 0)
  endif

  setlocal nomodifiable

  normal! zb

  if is_switch
    execute save_winnr . 'wincmd w'
  endif
endfunction"}}}
function! vimfiler#view#_force_redraw_all_vimfiler(...) "{{{
  let is_manualed = get(a:000, 0, 0)

  let current_nr = winnr()

  try
    " Search vimfiler window.
    for winnr in filter(range(1, winnr('$')),
          \ "getwinvar(v:val, '&filetype') ==# 'vimfiler'")
      execute winnr . 'wincmd w'
      call vimfiler#view#_force_redraw_screen(is_manualed)
    endfor
  finally
    execute current_nr . 'wincmd w'
  endtry
endfunction"}}}
function! vimfiler#view#_redraw_all_vimfiler() "{{{
  let current_nr = winnr()
  let bufnr = 1
  while bufnr <= winnr('$')
    " Search vimfiler window.
    if getwinvar(bufnr, '&filetype') ==# 'vimfiler'

      execute bufnr . 'wincmd w'
      call vimfiler#view#_redraw_screen()
    endif

    let bufnr += 1
  endwhile

  execute current_nr . 'wincmd w'
endfunction"}}}
function! vimfiler#view#_redraw_prompt() "{{{
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

  if line('$') == 1
    " Note: Dirty Hack for open file.
    call append(1, '')
    call setline(2, prefix .  dir . mask)
    delete _
  else
    call setline(1, prefix .  dir . mask)
  endif

  let &l:modifiable = modifiable_save
endfunction"}}}
function! vimfiler#view#_get_print_lines(files) "{{{
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
    if file.vimfiler__is_marked
      let mark .= g:vimfiler_marked_file_icon
    elseif file.vimfiler__is_directory
      let mark .= !get(file, 'vimfiler__is_readable', 1) ?
            \ g:vimfiler_readonly_file_icon :
            \ file.vimfiler__is_opened ? g:vimfiler_tree_opened_icon :
            \                            g:vimfiler_tree_closed_icon
    else
      let mark .= (!get(file, 'vimfiler__is_writable', 1) ?
          \      g:vimfiler_readonly_file_icon : g:vimfiler_file_icon)
    endif
    let mark .= ' '

    let filename = vimfiler#util#truncate_smart(
          \ mark . filename, max_len, max_len/2, '..')
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

function! s:get_filesize(file) "{{{
  if a:file.vimfiler__is_directory
    return '      '
  endif

  " Get human file size.
  let filesize = a:file.vimfiler__filesize
  if filesize < 0
    if a:file.action__path !~ '^\a\w\+:' &&
          \ has('python') && getftype(a:file.action__path) !=# 'link'
      let pattern = s:get_python_file_size(a:file.action__path)
    elseif filesize == -2
      " Above 2GB?
      let pattern = '>2.0'
    else
      let pattern = ''
    endif
    let suffix = (pattern != '') ? 'G' : ''
  elseif filesize < 1000
    " B.
    let suffix = 'B'
    let float = ''
    let pattern = printf('%5d', filesize)
  else
    if filesize >= 1000000000
      " GB.
      let suffix = 'G'
      let size = filesize / 1024 / 1024
    elseif filesize >= 1000000
      " MB.
      let suffix = 'M'
      let size = filesize / 1024
    elseif filesize >= 1000
      " KB.
      let suffix = 'K'
      let size = filesize
    endif

    let float = (size%1024)*100/1024
    let digit = size / 1024
    let pattern = (digit < 100) ?
          \ printf('%2d.%02d', digit, float) :
          \ printf('%2d.%01d', digit, float/10)
  endif

  return pattern.suffix
endfunction"}}}
function! s:get_python_file_size(filename) "{{{
    " Use python.
python <<END
import os.path
import vim
try:
  filesize = os.path.getsize(vim.eval(\
      'unite#util#iconv(a:filename, &encoding, "char")'))
except:
  filesize = -1
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
function! s:get_filetime(file) "{{{
  return (a:file.vimfiler__filetime =~ '^-\?\d\+$' ?
        \  (a:file.vimfiler__filetime == -1 ? '' :
        \    a:file.vimfiler__datemark .
        \    strftime(g:vimfiler_time_format, a:file.vimfiler__filetime))
        \ : a:file.vimfiler__datemark . a:file.vimfiler__filetime)
endfunction"}}}
function! s:convert_filetype(filetype) "{{{
  return ' ' . get({'[TXT]' : '~', '[IMG]' : '!',
        \ '[ARC]' : '@', '[EXE]' : '#', '[MUL]' : '$', '[DIR]' : '%',
        \ '[SYS]' : '^', '[LNK]' : '&',}, a:filetype, '')
endfunction"}}}

function! s:check_tree(files) "{{{
  let level = 0
  let _ = []
  for file in a:files
    if file.vimfiler__nest_level == 0 ||
          \ file.vimfiler__nest_level <= level + 1
      call add(_, file)
      let level = file.vimfiler__nest_level
    endif
  endfor

  return _
endfunction"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker

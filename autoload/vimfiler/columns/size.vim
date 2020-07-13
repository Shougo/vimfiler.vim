"=============================================================================
" FILE: size.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu at gmail.com>
" License: MIT license
"=============================================================================

function! vimfiler#columns#size#define() abort
  return s:column
endfunction

let s:column = {
      \ 'name' : 'size',
      \ 'description' : 'get filesize by human',
      \ 'syntax' : 'vimfilerColumn__Size',
      \ }

function! s:column.length(files, context) abort
  return 6
endfunction

function! s:column.define_syntax(context) abort
  syntax match   vimfilerColumn__SizeLine
        \ '.*' contained containedin=vimfilerColumn__Size
  highlight def link vimfilerColumn__SizeLine Constant
endfunction

function! s:column.get(file, context) abort
  if a:file.vimfiler__is_directory
    return '      '
  endif

  " Get human file size.
  let filesize = a:file.vimfiler__filesize
  let size = 0
  if filesize < 0
    if filesize == -2
      " Above 2GB?
      let pattern = '>2.00'
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

  return pattern . suffix
endfunction

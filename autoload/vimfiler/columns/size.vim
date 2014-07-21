"=============================================================================
" FILE: size.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
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

function! vimfiler#columns#size#define()
  return s:column
endfunction"}}}

let s:column = {
      \ 'name' : 'size',
      \ 'description' : 'get filesize by human',
      \ 'syntax' : 'vimfilerColumn__Size',
      \ }

function! s:column.length(files, context) "{{{
  return 6
endfunction"}}}

function! s:column.define_syntax(context) "{{{
  syntax match   vimfilerColumn__SizeLine
        \ '.*' contained containedin=vimfilerColumn__Size
  highlight def link vimfilerColumn__SizeLine Constant
endfunction"}}}

function! s:column.get(file, context) "{{{
  if a:file.vimfiler__is_directory
    return '      '
  endif

  " Get human file size.
  let filesize = a:file.vimfiler__filesize
  let size = 0
  if filesize < 0
    if a:file.action__path !~ '^\a\w\+:'
          \ && has('lua')
          \ && getftype(a:file.action__path) !=# 'link'
      let pattern = s:get_lua_file_size(a:file.action__path)
    elseif filesize == -2
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
endfunction"}}}

" @vimlint(EVL101, 1, l:pattern)
function! s:get_lua_file_size(filename) "{{{
  lua << EOF
do
  local file = io.open(vim.eval('iconv(a:filename, &encoding, "char")'))
  local pattern
  if file ~= nil then
    local mega = math.floor(file:seek('end') / (1024 * 1024) + 0.5)
    local float = math.floor((mega%1024)*100/1024 + 0.5)
    pattern = string.format('%2d.%02d', math.floor(mega/1024), float)
    file:close()
  else
    pattern = ''
  end
  vim.command('let pattern = "' .. pattern .. '"')
end
EOF

  return pattern
endfunction"}}}
" @vimlint(EVL101, 0, l:pattern)

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker

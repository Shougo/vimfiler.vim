"=============================================================================
" FILE: matcher_ignore_files.vim
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

function! vimfiler#filters#matcher_ignore_files#define()
  return s:filter
endfunction"}}}

let s:filter = {
      \ 'name' : 'matcher_ignore_files',
      \ 'description' : 'ignore project ignore files',
      \ }

function! s:filter.filter(files, context) "{{{
  let path = b:vimfiler.current_dir
  let project = unite#util#path2project_directory(path) . '/'

  if project ==# vimfiler#util#substitute_path_separator($HOME . '/')
    " Ignore
    return a:files
  endif

  let [project_ignore_patterns, project_ignore_whites] =
        \ unite#filters#matcher_project_ignore_files#get_ignore_results(project)

  return unite#filters#filter_patterns(a:files,
        \ project_ignore_patterns, project_ignore_whites)
endfunction"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker

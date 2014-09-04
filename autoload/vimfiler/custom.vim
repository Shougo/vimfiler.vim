"=============================================================================
" FILE: custom.vim
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

let s:save_cpo = &cpo
set cpo&vim

function! vimfiler#custom#get() "{{{
  if !exists('s:custom')
    let s:custom = {}
    let s:custom.profiles = {}
  endif

  return s:custom
endfunction"}}}

function! vimfiler#custom#profile(profile_name, option_name, value) "{{{
  let custom = vimfiler#custom#get()
  let profile_name =
        \ has_key(custom.profiles, a:profile_name) ?
        \ a:profile_name : 'default'

  for key in split(profile_name, '\s*,\s*')
    if !has_key(custom.profiles, key)
      let custom.profiles[key] = s:init_profile()
    endif

    let custom.profiles[key][a:option_name] = a:value
  endfor
endfunction"}}}
function! vimfiler#custom#get_profile(profile_name, option_name) "{{{
  let custom = vimfiler#custom#get()
  let profile_name =
        \ has_key(custom.profiles, a:profile_name) ?
        \ a:profile_name : 'default'

  if !has_key(custom.profiles, profile_name)
    let custom.profiles[profile_name] = s:init_profile()
  endif

  return custom.profiles[profile_name][a:option_name]
endfunction"}}}

function! s:init_profile() "{{{
  return {
        \ 'context' : {},
        \ }
endfunction"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker

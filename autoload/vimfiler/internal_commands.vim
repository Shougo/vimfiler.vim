"=============================================================================
" FILE: internal_commands.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>(Modified)
" Last Modified: 15 Jun 2010
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

function! vimfiler#internal_commands#cp(dest_dir, src_files)"{{{
    let l:dest_dir = fnamemodify(a:dest_dir, ':p')
    if !isdirectory(l:dest_dir)
        " Create directory.
        call mkdir(l:dest_dir, 'p')
    endif
    if l:dest_dir !~ '/$'
        let l:dest_dir .= '/'
    endif
    
    let l:current_len = len(b:vimfiler.current_dir . '/')
    for l:file in a:src_files
        let l:filename = b:vimfiler.current_dir . '/' . l:file
        if isdirectory(l:filename)
            if !isdirectory(l:dest_dir . l:filename[l:current_len :])
                call mkdir(l:dest_dir . l:filename[l:current_len :], 'p')
            endif
            
            for l:src_file in split(globpath(b:vimfiler.current_dir, l:file . '/**'), '\n')
                let l:dest_file = l:src_file[l:current_len :]
                if isdirectory(l:src_file)
                    call mkdir(l:dest_dir . l:dest_file, 'p')
                else
                    call writefile(readfile(l:src_file, 'b'), l:dest_dir . l:dest_file, 'b')
                endif
            endfor
        else
            let l:dest_file = l:filename[l:current_len :]
            call writefile(readfile(l:filename, 'b'), l:dest_dir . l:dest_file, 'b')
        endif
    endfor
endfunction"}}}
function! vimfiler#internal_commands#rm(files)"{{{
endfunction"}}}
function! vimfiler#internal_commands#cd(dir)"{{{
    if a:dir == '..'
        if b:vimfiler.current_dir =~ '^\a\+:/$\|^/$'
            " Ignore.
            return
        endif
        
        let l:dir = simplify(b:vimfiler.current_dir . '/' . a:dir)
    elseif a:dir == '/'
        " Root.
        let l:dir = vimfiler#iswin() ? 
                    \matchstr(fnamemodify(b:vimfiler.current_dir, ':p'), '^\a\+:/') : a:dir
    elseif a:dir == '~'
        " Home.
        let l:dir = expand('~')
    else
        let l:dir = a:dir
    endif
    
    if !isdirectory(l:dir)
        " Ignore.
        return
    endif
    
    let b:vimfiler.current_dir = l:dir
    if b:vimfiler.current_dir =~ '/$'
        let b:vimfiler.current_dir = b:vimfiler.current_dir[: -2]
    endif

    " Redraw.
    call vimfiler#redraw_screen()
endfunction"}}}

" vim: foldmethod=marker

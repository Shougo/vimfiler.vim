"=============================================================================
" FILE: internal_commands.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>(Modified)
" Last Modified: 01 Feb 2010
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
        let l:filename = l:file
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
        if b:vimfiler.current_dir =~ '^\a\+:$\|^/$'
            " Select drive.
            call vimfiler#mappings#move_to_drive()
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
    
    if l:dir[-1:] == '/' || l:dir[-1:] == '\'
        " Delete last '/'.
        let l:dir = l:dir[: -2]
    endif

    " Save current pos.
    let b:vimfiler.directory_cursor_pos[b:vimfiler.current_dir] = getpos('.')
    let b:vimfiler.current_dir = l:dir
    lcd `=l:dir`

    " Redraw.
    call vimfiler#redraw_screen()
    
    if has_key(b:vimfiler.directory_cursor_pos, l:dir)
        " Restore cursor pos.
        call setpos('.', b:vimfiler.directory_cursor_pos[l:dir])
    endif
endfunction"}}}
function! vimfiler#internal_commands#open(filename)"{{{
    if &termencoding != '' && &encoding != &termencoding
        " Convert encoding.
        let l:filename = iconv(a:filename, &encoding, &termencoding)
    else
        let l:filename = a:filename
    endif

    " Detect desktop environment.
    if vimfiler#iswin()
        if executable('cmdproxy.exe') && exists('*vimproc#system')
            " Use vimproc.
            call vimproc#system(printf('cmdproxy /C "start \"\" \"%s\""', a:filename))
        else
            execute printf('silent ! start "" "%s"', a:filename)
        endif
    elseif has('mac')
        call system('open ''' . a:filename . ''' &')
    elseif exists('$KDE_FULL_SESSION') && $KDE_FULL_SESSION ==# 'true'
        " KDE.
        call system('kfmclient exec ''' . a:filename . ''' &')
    elseif exists('$GNOME_DESKTOP_SESSION_ID')
        " GNOME.
        call system('gnome-open ''' . a:filename . ''' &')
    elseif executable(vimshell#getfilename('exo-open'))
        " Xfce.
        call system('exo-open ''' . a:filename . ''' &')
    else
        throw 'Not supported.'
    endif
endfunction"}}}
function! vimfiler#internal_commands#gexe(filename)"{{{
    if vimfiler#iswin()
        if a:filename !=# 'gvim' && executable('cmdproxy.exe') && exists('*vimproc#system')
            " Use vimproc.
            let l:commands = split(a:filename)
            call vimproc#system(printf('cmdproxy /C "start \"\" \"%s\" %s"', l:commands[0], join(l:commands[1:])))
        else
            execute 'silent ! start ' a:filename
        endif
    else
        " For *nix.

        " Background execute.
        call system(a:filename . '&')
    endif
endfunction"}}}

" vim: foldmethod=marker

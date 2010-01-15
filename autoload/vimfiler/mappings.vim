"=============================================================================
" FILE: mappings.vim
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

" vimfiler key-mappings functions."{{{
function! vimfiler#mappings#toggle_mark_current_line()"{{{
    let l:line = getline('.')
    if !vimfiler#check_filename_line(l:line)
        " Don't toggle.
        return
    endif
    setlocal modifiable
    
    call setline('.', (l:line[0] == '*'? '-' : '*') . l:line[1:])
    
    normal! j
    setlocal nomodifiable
endfunction"}}}
function! vimfiler#mappings#toggle_mark_all_lines()"{{{
    setlocal modifiable
    
    let l:max = line('$')
    let l:cnt = 1
    while l:cnt <= l:max
        let l:line = getline(l:cnt)
        if vimfiler#check_filename_line(l:line)
            " Toggle line.
            call setline(l:cnt, (l:line[0] == '*'? '-' : '*') . l:line[1:])
        endif

        let l:cnt += 1
    endwhile
    
    setlocal nomodifiable
endfunction"}}}
function! vimfiler#mappings#copy()"{{{
    let l:marked_files = vimfiler#get_marked_files()
    if empty(l:marked_files)
        " Mark current line.
        call vimfiler#mappings#toggle_mark_current_line()
        return
    endif

    " Get destination directory.
    let l:dest_dir = vimfiler#input_directory('Please input destination directory:')
    if l:dest_dir == ''
        " Cancel.
        return
    endif
    
    " Execute copy.
    call vimfiler#internal_commands#cp(l:dest_dir, l:marked_files)
endfunction"}}}
function! vimfiler#mappings#execute_file()"{{{
    let l:line = getline('.')
    if !vimfiler#check_filename_line(l:line)
        return
    endif

    let l:filename = b:vimfiler.current_dir . '/' . vimfiler#get_filename(l:line)
    if isdirectory(l:filename)
        " Change directory.
        call vimfiler#internal_commands#cd(l:filename)
    else
        let l:filename = fnamemodify(l:filename, ':p')
        if &termencoding != '' && &encoding != &termencoding
            " Convert encoding.
            let l:filename = iconv(l:filename, &encoding, &termencoding)
        endif
        
        " Execute cursor file.

        " Detect desktop environment.
        if vimfiler#iswin()
            execute printf('silent ! start "" "%s"', l:filename)
        elseif has('mac')
            call system('open ''' . l:filename . ''' &')
        elseif exists('$KDE_FULL_SESSION') && $KDE_FULL_SESSION ==# 'true'
            " KDE.
            call system('kfmclient exec ''' . l:filename . ''' &')
        elseif exists('$GNOME_DESKTOP_SESSION_ID')
            " GNOME.
            call system('gnome-open ''' . l:filename . ''' &')
        elseif executable(vimshell#getfilename('exo-open'))
            " Xfce.
            call system('exo-open ''' . l:filename . ''' &')
        else
            throw 'Not supported.'
        endif
    endif
endfunction"}}}

"}}}
" vim: foldmethod=marker

"=============================================================================
" FILE: vimfiler.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
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
" Version: 1.00, for Vim 7.0
"=============================================================================

" Check vimproc.
let s:is_vimproc = exists('*vimproc#system')

augroup VimFilerAutoCmd"{{{
    autocmd!
    autocmd BufWinEnter * if &filetype == 'vimfiler' | call s:event_bufwin_enter()
    autocmd BufWinLeave * if &filetype == 'vimfiler' | call s:event_bufwin_leave()
augroup end"}}}

" Plugin keymappings"{{{
nnoremap <silent> <Plug>(vimfiler_toggle_mark_current_line)  :<C-u>call vimfiler#mappings#toggle_mark_current_line()<CR>
nnoremap <silent> <Plug>(vimfiler_toggle_mark_all_lines)  :<C-u>call vimfiler#mappings#toggle_mark_all_lines()<CR>
nnoremap <silent> <Plug>(vimfiler_copy)  :<C-u>call vimfiler#mappings#copy()<CR>
nnoremap <silent> <Plug>(vimfiler_execute_file)  :<C-u>call vimfiler#mappings#execute_file()<CR>
nnoremap <silent> <Plug>(vimfiler_move_to_up_directory)  :<C-u>call vimfiler#internal_commands#cd('..')<CR>
nnoremap <silent> <Plug>(vimfiler_move_to_home_directory)  :<C-u>call vimfiler#internal_commands#cd('~')<CR>
nnoremap <silent> <Plug>(vimfiler_move_to_root_directory)  :<C-u>call vimfiler#internal_commands#cd('/')<CR>
"}}}

" User utility functions."{{{
function! vimfiler#default_settings()"{{{
    setlocal buftype=nofile
    setlocal noswapfile
    setlocal bufhidden=hide
    setlocal nomodifiable
    setlocal nowrap
    setlocal cursorline

    " Normal mode key-mappings."{{{
    " Toggle mark.
    nmap <buffer> <Space> <Plug>(vimfiler_toggle_mark_current_line)
    " Toggle mark in all lines.
    nmap <buffer> * <Plug>(vimfiler_toggle_mark_all_lines)
    " Copy.
    nmap <buffer> C <Plug>(vimfiler_copy)
    " Execute or change directory.
    nmap <buffer> <Enter> <Plug>(vimfiler_execute_file)
    nmap <buffer> h <Plug>(vimfiler_move_to_up_directory)
    nmap <buffer> <C-h> <Plug>(vimfiler_move_to_up_directory)
    nmap <buffer> ~ <Plug>(vimfiler_move_to_home_directory)
    nmap <buffer> \ <Plug>(vimfiler_move_to_root_directory)
    "}}}
endfunction"}}}
"}}}

" vimfiler plugin utility functions."{{{
function! vimfiler#create_filer(split_flag, directory)"{{{
    let l:bufname = '[1]vimfiler'
    let l:cnt = 2
    while bufexists(l:bufname)
        let l:bufname = printf('[%d]vimfiler', l:cnt)
        let l:cnt += 1
    endwhile

    if a:split_flag
        split `=l:bufname`
    else
        edit `=l:bufname`
    endif

    call vimfiler#default_settings()
    setfiletype vimfiler

    let b:vimfiler = {}

    " Set current directory.
    let b:vimfiler.current_dir = (a:directory != '')? a:directory : getcwd()
    if b:vimfiler.current_dir =~ '/$'
        let b:vimfiler.current_dir = b:vimfiler.current_dir[: -2]
    endif
    
    call vimfiler#redraw_screen()
endfunction"}}}
function! vimfiler#switch_filer(split_flag, directory)"{{{
    if &filetype == 'vimfiler'
        if winnr('$') != 1
            close
        else
            buffer #
        endif

        if a:directory != ''
            " Change current directory.
            let b:vimfiler.current_dir = a:directory
            if b:vimfiler.current_dir =~ '/$'
                let b:vimfiler.current_dir = b:vimfiler.current_dir[: -2]
            endif
        endif

        call vimfiler#redraw_screen()
        return
    endif

    " Search vimfiler window.
    let l:cnt = 1
    while l:cnt <= winnr('$')
        if getwinvar(l:cnt, '&filetype') == 'vimfiler'

            execute l:cnt . 'wincmd w'

            if a:directory != ''
                " Change current directory.
                let b:vimfiler.current_dir = a:directory
                if b:vimfiler.current_dir =~ '/$'
                    let b:vimfiler.current_dir = b:vimfiler.current_dir[: -2]
                endif
            endif
            
            call vimfiler#redraw_screen()
            return
        endif

        let l:cnt += 1
    endwhile

    " Search vimfiler buffer.
    let l:cnt = 1
    while l:cnt <= bufnr('$')
        if getbufvar(l:cnt, '&filetype') == 'vimfiler'
            if a:split_flag
                execute 'sbuffer' . l:cnt
            else
                execute 'buffer' . l:cnt
            endif

            if a:directory != ''
                " Change current directory.
                let b:vimfiler.current_dir = a:directory
                if b:vimfiler.current_dir =~ '/$'
                    let b:vimfiler.current_dir = b:vimfiler.current_dir[: -2]
                endif
            endif
            
            call vimfiler#redraw_screen()
            return
        endif

        let l:cnt += 1
    endwhile

    " Create window.
    call vimfiler#create_filer(a:split_flag, a:directory)
endfunction"}}}
function! vimfiler#redraw_screen()"{{{
    setlocal modifiable
    
    " Clean up the screen.
    % delete _
    
    " Print current directory.
    let l:mask = '/*'
    call setline(1, 'Current directory: ' . b:vimfiler.current_dir . l:mask)
    
    " Append up directory.
    call append('$', '..')

    " Print files.
    for l:file in split(glob(b:vimfiler.current_dir . l:mask), '\n')
        call append('$', printf('-   %-50s    %s',
                    \ vimfiler#smart_omit_filename(fnamemodify(l:file, ':t'), 50) . (isdirectory(fnamemodify(l:file, ':p'))? '/' : ''), 
                    \ strftime('~%y/%m/%d %H:%M', getftime(l:file))
                    \))
    endfor
    
    setlocal nomodifiable
endfunction"}}}
function! vimfiler#iswin()"{{{
    return has('win32') || has('win64')
endfunction"}}}
function! vimfiler#system(str, ...)"{{{
    return s:is_vimproc ? (a:0 == 0 ? vimproc#system(a:str) : vimproc#system(a:str, join(a:000)))
                \: (a:0 == 0 ? system(a:str) : system(a:str, join(a:000)))
endfunction"}}}
function! vimfiler#get_marked_files()"{{{
    let l:files = []
    let l:max = line('$')
    let l:cnt = 1
    while l:cnt <= l:max
        let l:line = getline(l:cnt)
        if l:line =~ '^[*] '
            " Marked.
            call add(l:files, vimfiler#get_filename(l:line))
        endif
        
        let l:cnt += 1
    endwhile

    return l:files
endfunction"}}}
function! vimfiler#check_filename_line(line)"{{{
    return a:line == '..' || a:line =~ '^[*-] '
endfunction"}}}
function! vimfiler#get_filename(line)"{{{
    return a:line == '..'? a:line : matchstr(a:line, '\s\zs\%(\f\%(\s\f\)\?\)\+')
endfunction"}}}
function! vimfiler#input_directory(message)"{{{
    let l:current_dir_save = getcwd()

    lcd `=b:vimfiler.current_dir`
    echo a:message
    let l:dir = input('', '', 'dir')
    while !isdirectory(l:dir)
        redraw
        if l:dir == ''
            echo 'Canceled.'
            break
        endif
        
        " Retry.
        echohl WarningMsg | echo 'Invalid path.' | echohl None
        echo a:message
        let l:dir = input('', '', 'dir')
    endwhile
    
    " Restore working directory.
    lcd `=l:current_dir_save`

    return l:dir
endfunction"}}}
function! vimfiler#smart_omit_filename(filename, length)"{{{
    if len(a:filename) <= a:length
        return a:filename
    endif
    
    let l:over_len = len(a:filename) - a:length
    let l:prefix_len = (l:over_len > 10) ?  10 : l:over_len
    return printf('%s~%s', a:filename[: l:prefix_len - 1], a:filename[l:over_len+l:prefix_len :])
endfunction"}}}
"}}}

" Event functions.
function! s:event_bufwin_enter()"{{{
    setlocal cursorline
endfunction"}}}
function! s:event_bufwin_leave()"{{{
    setlocal nocursorline
endfunction"}}}

" vim: foldmethod=marker

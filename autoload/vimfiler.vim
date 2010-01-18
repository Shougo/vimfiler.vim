"=============================================================================
" FILE: vimfiler.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 17 Jun 2010
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
nnoremap <silent> <Plug>(vimfiler_loop_cursor_down)  :<C-u>call vimfiler#mappings#loop_cursor_down()<CR>
nnoremap <silent> <Plug>(vimfiler_loop_cursor_up)  :<C-u>call vimfiler#mappings#loop_cursor_up()<CR>
nnoremap <silent> <Plug>(vimfiler_redraw_screen)  :<C-u>call vimfiler#redraw_screen()<CR>
nnoremap <silent> <Plug>(vimfiler_toggle_mark_current_line)  :<C-u>call vimfiler#mappings#toggle_mark_current_line()<CR>j
nnoremap <silent> <Plug>(vimfiler_toggle_mark_all_lines)  :<C-u>call vimfiler#mappings#toggle_mark_all_lines()<CR>
nnoremap <silent> <Plug>(vimfiler_copy)  :<C-u>call vimfiler#mappings#copy()<CR>
nnoremap <silent> <Plug>(vimfiler_execute_file)  :<C-u>call vimfiler#mappings#execute_file()<CR>
nnoremap <silent> <Plug>(vimfiler_move_to_up_directory)  :<C-u>call vimfiler#internal_commands#cd('..')<CR>
nnoremap <silent> <Plug>(vimfiler_move_to_home_directory)  :<C-u>call vimfiler#internal_commands#cd('~')<CR>
nnoremap <silent> <Plug>(vimfiler_move_to_root_directory)  :<C-u>call vimfiler#internal_commands#cd('/')<CR>
nnoremap <silent> <Plug>(vimfiler_move_to_drive)  :<C-u>call vimfiler#mappings#move_to_drive()<CR>
nnoremap <silent> <Plug>(vimfiler_execute_new_gvim)  :<C-u>call vimfiler#internal_commands#gexe('gvim')<CR>
nnoremap <silent> <Plug>(vimfiler_toggle_visible_dot_files)  :<C-u>call vimfiler#mappings#toggle_visible_dot_files()<CR>
nnoremap <silent> <Plug>(vimfiler_popup_shell)  :<C-u>call vimfiler#mappings#popup_shell()<CR>
nnoremap <silent> <Plug>(vimfiler_edit_file)  :<C-u>call vimfiler#mappings#edit_file()<CR>
nnoremap <silent> <Plug>(vimfiler_execute_external_filer)  :<C-u>call vimfiler#internal_commands#open(b:vimfiler.current_dir)<CR>
nnoremap <silent> <Plug>(vimfiler_execute_external_command)  :<C-u>call vimfiler#mappings#execute_external_command()<CR>
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
    nmap <buffer> j <Plug>(vimfiler_loop_cursor_down)
    nmap <buffer> k <Plug>(vimfiler_loop_cursor_up)
    " Toggle mark.
    nmap <buffer> <C-l> <Plug>(vimfiler_redraw_screen)
    nmap <buffer> <Space> <Plug>(vimfiler_toggle_mark_current_line)
    " Toggle mark in all lines.
    nmap <buffer> * <Plug>(vimfiler_toggle_mark_all_lines)
    " Copy.
    nmap <buffer> c <Plug>(vimfiler_copy)
    nmap <buffer> C <Plug>(vimfiler_copy)
    " Execute or change directory.
    nmap <buffer> <Enter> <Plug>(vimfiler_execute_file)
    nmap <buffer> ' <Plug>(vimfiler_execute_file)
    nmap <buffer> o <Plug>(vimfiler_execute_file)
    nmap <buffer> h <Plug>(vimfiler_move_to_up_directory)
    nmap <buffer> L <Plug>(vimfiler_move_to_drive)
    nmap <buffer> <C-h> <Plug>(vimfiler_move_to_up_directory)
    nmap <buffer> ~ <Plug>(vimfiler_move_to_home_directory)
    nmap <buffer> \ <Plug>(vimfiler_move_to_root_directory)
    nmap <buffer> V <Plug>(vimfiler_execute_new_gvim)
    nmap <buffer> . <Plug>(vimfiler_toggle_visible_dot_files)
    nmap <buffer> H <Plug>(vimfiler_popup_shell)
    nmap <buffer> e <Plug>(vimfiler_edit_file)
    nmap <buffer> E <Plug>(vimfiler_execute_external_filer)
    nmap <buffer> t <Plug>(vimfiler_execute_external_command)
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
        vsplit `=l:bufname`
    else
        edit `=l:bufname`
    endif

    call vimfiler#default_settings()
    setfiletype vimfiler

    let b:vimfiler = {}

    " Set current directory.
    let b:vimfiler.save_current_dir = getcwd()
    let l:current = (a:directory != '')? a:directory : getcwd()
    lcd `=l:current`
    let b:vimfiler.current_dir = (a:directory != '')? a:directory : getcwd()
    if b:vimfiler.current_dir =~ '/$'
        let b:vimfiler.current_dir = b:vimfiler.current_dir[: -2]
    endif
    let b:vimfiler.is_visible_dot_files = 0
    
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
    let b:vimfiler.filename_list = split(glob(b:vimfiler.current_dir . l:mask), '\n')
    if b:vimfiler.is_visible_dot_files
        let b:vimfiler.filename_list += filter(split(glob(b:vimfiler.current_dir . '/.*'), '\n'), 
                    \'v:val !~ ''[/\\]\.\.\?$''')
    endif
    for l:file in b:vimfiler.filename_list
        let l:filename = fnamemodify(l:file, ':p')
        if isdirectory(l:filename)
            call append('$', printf('%s  %s  %s ',
                        \ vimfiler#get_filemark(l:filename), 
                        \ vimfiler#smart_omit_filename(fnamemodify(l:file, ':t').'/', 50), 
                        \ vimfiler#get_filetype(l:filename)
                        \))
        else
            call append('$', printf('%s  %s  %s  %-10s  %s%s',
                        \ vimfiler#get_filemark(l:filename), 
                        \ vimfiler#smart_omit_filename(fnamemodify(l:file, ':t'), 50), 
                        \ vimfiler#get_filetype(l:filename), 
                        \ getfsize(l:filename), 
                        \ vimfiler#get_datemark(l:filename), 
                        \ strftime('%y/%m/%d %H:%M', getftime(l:filename))
                        \))
        endif
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
            call add(l:files, vimfiler#get_filename(l:cnt))
        endif
        
        let l:cnt += 1
    endwhile

    return l:files
endfunction"}}}
function! vimfiler#check_filename_line(line)"{{{
    return a:line == '..' || a:line =~ '^[*+-]\s'
endfunction"}}}
function! vimfiler#get_filename(line_num)"{{{
    return getline(a:line_num) == '..'? '..' : b:vimfiler.filename_list[a:line_num - 3]
endfunction"}}}
function! vimfiler#input_directory(message)"{{{
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
    
    return l:dir
endfunction"}}}
function! vimfiler#get_alternate_directory()"{{{
    let l:filetype = getbufvar(bufnr('#'), '&filetype')
    if l:filetype != 'vimfiler'
        return ''
    else
        return getbufvar(bufnr('#'), 'vimfiler').current_dir
    endif
endfunction"}}}
function! vimfiler#redraw_alternate_vimfiler()"{{{
    " Search vimfiler window.
    if getwinvar(winnr('#'), '&filetype') == 'vimfiler'

        execute winnr('#') . 'wincmd w'
        call vimfiler#redraw_screen()
        execute winnr('#') . 'wincmd w'
    endif
endfunction"}}}
function! vimfiler#smart_omit_filename(filename, length)"{{{
    let l:len = len(a:filename)
    if a:filename !~ '[^[:print:]]'
        return printf('%.' . a:length . 's%s', a:filename, repeat(' ', a:length - l:len))
    endif

    " For multibyte.
    let l:pos = 0
    let l:fchar = char2nr(a:filename[l:pos])
    let l:display_diff = 0
    while l:pos < l:len && l:pos-l:display_diff < a:length
        if l:fchar >= 0x80
            " Skip multibyte
            if l:fchar < 0xc0
                " Skip UTF-8 on the way
                let l:fchar = char2nr(a:filename[l:pos])
                while l:pos < a:length && 0x80 <= l:fchar && l:fchar < 0xc0
                    let l:pos += 1
                    let l:fchar = char2nr(a:filename[l:pos])
                endwhile
            elseif l:fchar < 0xe0
                " 2byte code
                let l:pos += 1
            elseif l:fchar < 0xf0
                " 3byte code
                let l:display_diff += 1
                let l:pos += 2
            elseif l:fchar < 0xf8
                " 4byte code
                let l:display_diff += 2
                let l:pos += 3
            elseif l:fchar < 0xfe
                " 5byte code
                let l:display_diff += 3
                let l:pos += 4
            else
                " 6byte code
                let l:display_diff += 4
                let l:pos += 5
            endif
        endif

        let l:pos += 1
        let l:fchar = char2nr(a:filename[l:pos])
    endwhile
    
    return printf('%.' . l:pos . 's%s', a:filename, repeat(' ', a:length - l:pos+l:display_diff))
endfunction"}}}
function! vimfiler#get_filemark(filename)"{{{
    if !filewritable(a:filename)
        " Read only.
        return '-'
    else
        " Others.
        return '+'
    endif
endfunction"}}}
function! vimfiler#get_filetype(filename)"{{{
    let l:ext = fnamemodify(a:filename, ':e')
    if l:ext =~? 
                \'^\%(txt\|cfg\|ini\)$'
        " Text.
        return '[TXT]'
    elseif l:ext =~?
                \'^\%(bmp\|png\|gif\|jpg\|jpeg\|jp2\|tif\|ico\|wdp\|cur\|ani\)$'
        " Image.
        return '[IMG]'
    elseif l:ext =~? 
                \'^\%(lzh\|zip\|gz\|bz2\|cab\|rar\|7z\|tgz\|tar\)$'
        " Archive.
        return '[ARC]'
    elseif (!vimfiler#iswin() && executable(a:filename))
                \|| l:ext =~? 
                \'^\%(exe\|com\|bat\|cmd\|vbs\|vbe\|js\|jse\|wsf\|wsh\|msc\|pif\|msi\|ps1\)$'
        " Execute.
        return '[EXE]'
    elseif l:ext =~?
                \'^\%(avi\|asf\|wmv\|mpg\|flv\|swf\|divx\|mov\|mpa\|m1a\|m2p\|m2a\|mpeg\|m1v\|m2v\|mp2v\|mp4\|qt\|ra\|rm\|ram\|rmvb\|rpm\|smi\|mkv\|mid\|wav\|mp3\|ogg\|wma\|au\)$'
        " Multimedia.
        return '[MUL]'
    elseif isdirectory(a:filename)
        " Directiory.
        return '[DIR]'
    elseif a:filename =~ '^\.' || l:ext =~? 
                \'^\%(inf\|sys\|reg\|dat\|spi\|a\|so\|lib\)$'
        " System.
        return '[SYS]'
    else
        " Others filetype.
        return '     '
    endif
endfunction"}}}
function! vimfiler#get_datemark(filename)"{{{
    let l:time = localtime() - getftime(a:filename)
    if l:time < 86400
        " 60 * 60 * 24
        return '!'
    elseif l:time < 604800
        " 60 * 60 * 24 * 7
        return '#'
    else
        return '~'
    endif
endfunction"}}}
"}}}

" Event functions.
function! s:event_bufwin_enter()"{{{
    let b:vimfiler.save_current_dir = getcwd()
    lcd `b:vimfiler.current_dir`
endfunction"}}}
function! s:event_bufwin_leave()"{{{
    lcd `b:vimfiler.save_current_dir`
endfunction"}}}

" vim: foldmethod=marker

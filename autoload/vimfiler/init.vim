"=============================================================================
" FILE: init.vim
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

" Global options definition. "{{{
let g:vimfiler_split_action =
      \ get(g:, 'vimfiler_split_action', 'right')
let g:vimfiler_edit_action =
      \ get(g:, 'vimfiler_edit_action', 'open')
let g:vimfiler_preview_action =
      \ get(g:, 'vimfiler_preview_action', 'preview')
let g:vimfiler_sort_type =
      \ get(g:, 'vimfiler_sort_type', 'filename')
let g:vimfiler_directory_display_top =
      \ get(g:, 'vimfiler_directory_display_top', 1)
let g:vimfiler_max_directories_history =
      \ get(g:, 'vimfiler_max_directories_history', 50)
let g:vimfiler_safe_mode_by_default =
      \ get(g:, 'vimfiler_safe_mode_by_default', 1)
let g:vimfiler_force_overwrite_statusline =
      \ get(g:, 'vimfiler_force_overwrite_statusline', 1)
let g:vimfiler_time_format =
      \ get(g:, 'vimfiler_time_format', '%y/%m/%d %H:%M')
let g:vimfiler_tree_leaf_icon =
      \ get(g:, 'vimfiler_tree_leaf_icon', '|')
let g:vimfiler_tree_opened_icon =
      \ get(g:, 'vimfiler_tree_opened_icon', '-')
let g:vimfiler_tree_closed_icon =
      \ get(g:, 'vimfiler_tree_closed_icon', '+')
let g:vimfiler_tree_indentation =
      \ get(g:, 'vimfiler_tree_indentation', 1)
let g:vimfiler_file_icon =
      \ get(g:, 'vimfiler_file_icon', ' ')
let g:vimfiler_readonly_file_icon =
      \ get(g:, 'vimfiler_readonly_file_icon', 'X')
let g:vimfiler_marked_file_icon =
      \ get(g:, 'vimfiler_marked_file_icon', '*')
let g:vimfiler_quick_look_command =
      \ get(g:, 'vimfiler_quick_look_command', '')
let g:vimfiler_explorer_columns =
      \ get(g:, 'vimfiler_explorer_columns', 'type')
let g:vimfiler_ignore_pattern =
      \ get(g:, 'vimfiler_ignore_pattern', '^\.')
let g:vimfiler_expand_jump_to_first_child =
      \ get(g:, 'vimfiler_expand_jump_to_first_child', 1)
let g:vimfiler_restore_alternate_file =
      \ get(g:, 'vimfiler_restore_alternate_file', 1)

let g:vimfiler_execute_file_list =
      \ get(g:, 'vimfiler_execute_file_list', {})

" Set extensions.
let g:vimfiler_extensions =
      \ get(g:, 'vimfiler_extensions', {})
if !has_key(g:vimfiler_extensions, 'text')
  call vimfiler#set_extensions('text',
        \ 'txt,cfg,ini')
endif
if !has_key(g:vimfiler_extensions, 'image')
  call vimfiler#set_extensions('image',
        \ 'bmp,png,gif,jpg,jpeg,jp2,tif,ico,wdp,cur,ani')
endif
if !has_key(g:vimfiler_extensions, 'archive')
  call vimfiler#set_extensions('archive',
        \ 'lzh,zip,gz,bz2,cab,rar,7z,tgz,tar')
endif
if !has_key(g:vimfiler_extensions, 'system')
  call vimfiler#set_extensions('system',
        \ 'inf,sys,reg,dat,spi,a,so,lib,dll')
endif
if !has_key(g:vimfiler_extensions, 'multimedia')
  call vimfiler#set_extensions('multimedia',
        \ 'avi,asf,wmv,mpg,flv,swf,divx,mov,mpa,m1a,'.
        \ 'm2p,m2a,mpeg,m1v,m2v,mp2v,mp4,qt,ra,rm,ram,'.
        \ 'rmvb,rpm,smi,mkv,mid,wav,mp3,ogg,wma,au,flac'
        \ )
endif
"}}}

let s:manager = vimfiler#util#get_vital().import('Vim.Buffer')

let s:loaded_columns = {}

function! vimfiler#init#_initialize() "{{{
  " Dummy initialize
endfunction"}}}
function! vimfiler#init#_command(default, args) "{{{
  let args = []
  let options = a:default
  for arg in split(a:args, '\%(\\\@<!\s\)\+')
    let arg = substitute(arg, '\\\( \)', '\1', 'g')

    let arg_key = substitute(arg, '=\zs.*$', '', '')
    let matched_list = filter(copy(vimfiler#variables#options()),
          \  'v:val ==# arg_key')
    for option in matched_list
      let key = substitute(substitute(option, '-', '_', 'g'),
            \ '=$', '', '')[1:]
      let options[key] = (option =~ '=$') ?
            \ arg[len(option) :] : 1
      break
    endfor

    if empty(matched_list)
      call add(args, arg)
    endif
  endfor

  call vimfiler#init#_start(join(args), options)
endfunction"}}}
function! vimfiler#init#_context(context) "{{{
  let default_context = vimfiler#variables#default_context()

  if get(a:context, 'explorer', 0)
    " Change default value.
    let default_context.buffer_name = 'explorer'
    let default_context.split = 1
    let default_context.simple = 1
    let default_context.toggle = 1
    let default_context.quit = 0
    let default_context.winwidth = 35
    let default_context.columns = g:vimfiler_explorer_columns
  endif

  let context = extend(default_context, a:context)

  " Generic no.
  for option in map(filter(items(context),
        \ "stridx(v:val[0], 'no_') == 0 && v:val[1]"), 'v:val[0]')
    let context[option[3:]] = 0
  endfor

  if !has_key(context, 'profile_name')
    let context.profile_name = context.buffer_name
  endif
  if context.toggle && context.find
    " Disable toggle feature.
    let context.toggle = 0
  endif
  if context.tab
    " Force create new vimfiler buffer.
    let context.create = 1
    let context.alternate_buffer = -1
  endif

  return context
endfunction"}}}
function! vimfiler#init#_vimfiler_directory(directory, context) "{{{1
  " Set current unite.
  let b:vimfiler.unite = unite#get_current_unite()

  " Set current directory.
  let current = vimfiler#util#substitute_path_separator(a:directory)
  let b:vimfiler.current_dir = current
  if b:vimfiler.current_dir !~ '[:/]$'
    let b:vimfiler.current_dir .= '/'
  endif
  let b:vimfiler.all_files = []
  let b:vimfiler.current_files = []
  let b:vimfiler.original_files = []
  let b:vimfiler.all_files_len = 0

  let b:vimfiler.is_visible_ignore_files = 0
  let b:vimfiler.simple = a:context.simple
  let b:vimfiler.directory_cursor_pos = {}
  let b:vimfiler.current_mask = ''

  let b:vimfiler.column_names = split(a:context.columns, ':')
  let b:vimfiler.columns = vimfiler#init#_columns(
        \ b:vimfiler.column_names, b:vimfiler.context)
  let b:vimfiler.syntaxes = []

  let b:vimfiler.global_sort_type = g:vimfiler_sort_type
  let b:vimfiler.local_sort_type = g:vimfiler_sort_type
  let b:vimfiler.is_safe_mode = g:vimfiler_safe_mode_by_default
  let b:vimfiler.winwidth = winwidth(0)
  let b:vimfiler.another_vimfiler_bufnr = -1
  let b:vimfiler.prompt_linenr =
        \ (b:vimfiler.context.explorer) ?  0 :
        \ (b:vimfiler.context.status)   ?  2 : 1
  let b:vimfiler.all_files_len = 0
  let b:vimfiler.status = ''
  let b:vimfiler.statusline =
        \ (b:vimfiler.context.explorer ?  '' : '*vimfiler* : ')
        \ . '%{vimfiler#get_status_string()}'
        \ . "\ %=%{exists('b:vimfiler') ? printf('%4d/%d',line('.'),
        \    b:vimfiler.prompt_linenr+b:vimfiler.all_files_len) : ''}"
  call vimfiler#set_current_vimfiler(b:vimfiler)

  call vimfiler#default_settings()
  call vimfiler#mappings#define_default_mappings(a:context)

  set filetype=vimfiler

  if b:vimfiler.context.double
    " Create another vimfiler.
    call vimfiler#mappings#create_another_vimfiler()
    wincmd p
  endif

  if a:context.winwidth >= 0
    execute 'vertical resize' a:context.winwidth
  endif

  call vimfiler#view#_define_syntax()
  call vimfiler#view#_force_redraw_all_vimfiler()

  " Initialize cursor position.
  call cursor(b:vimfiler.prompt_linenr+1, 0)

  if a:context.auto_cd
    " Change current directory.
    call vimfiler#mappings#_change_vim_current_dir()
  endif

  call vimfiler#mappings#cd(b:vimfiler.current_dir)
endfunction"}}}
function! vimfiler#init#_vimfiler_file(path, lines, dict) "{{{1
  " Set current unite.
  let b:vimfiler.unite = unite#get_current_unite()

  " Set current directory.
  let b:vimfiler.current_path = a:path
  let b:vimfiler.current_file = a:dict

  " Clean up the screen.
  silent % delete _

  augroup vimfiler
    autocmd! * <buffer>
    autocmd BufWriteCmd <buffer>
          \ call vimfiler#handler#_event_handler('BufWriteCmd')
  augroup END

  call setline(1, a:lines)

  setlocal buftype=acwrite
  setlocal noswapfile

  " For filetype detect.
  execute 'doautocmd BufRead' fnamemodify(a:path[-1], ':t')

  let &fileencoding = get(a:dict, 'vimfiler__encoding', '')

  setlocal nomodified
endfunction"}}}
function! vimfiler#init#_candidates(candidates, source_name) "{{{
  let default = {
        \ 'vimfiler__is_directory' : 0,
        \ 'vimfiler__is_executable' : 0,
        \ 'vimfiler__is_writable' : 1,
        \ 'vimfiler__filesize' : -1,
        \ 'vimfiler__filetime' : 0,
        \}
  " Set default vimfiler property.
  for candidate in a:candidates
    let candidate = extend(candidate, default, 'keep')

    if !has_key(candidate, 'vimfiler__filename')
      let candidate.vimfiler__filename = candidate.word
    endif
    if !has_key(candidate, 'vimfiler__abbr')
      let candidate.vimfiler__abbr = candidate.word
    endif
    if !has_key(candidate, 'vimfiler__datemark')
      let candidate.vimfiler__datemark = vimfiler#get_datemark(candidate)
    endif
    if !has_key(candidate, 'vimfiler__extension')
      let candidate.vimfiler__extension =
            \ candidate.vimfiler__is_directory ?
            \ '' : fnamemodify(candidate.vimfiler__filename, ':e')
    endif
    if !has_key(candidate, 'vimfiler__filetype')
      let candidate.vimfiler__filetype = vimfiler#get_filetype(candidate)
    endif

    let candidate.vimfiler__is_marked = 0
    let candidate.source = a:source_name
    let candidate.unite__abbr = candidate.vimfiler__abbr
  endfor

  return a:candidates
endfunction"}}}
function! vimfiler#init#_columns(columns, context) "{{{
  let columns = []

  for column in a:columns
    if !has_key(s:loaded_columns, column)
      let name = substitute(column, '^[^/_]\+\zs[/_].*$', '', '')

      for define in map(split(globpath(&runtimepath,
            \ 'autoload/vimfiler/columns/'.name.'*.vim'), '\n'),
            \ "vimfiler#columns#{fnamemodify(v:val, ':t:r')}#define()")
        for dict in vimfiler#util#convert2list(define)
          if !empty(dict) && !has_key(s:loaded_columns, dict.name)
            let s:loaded_columns[dict.name] = dict
          endif
        endfor
        unlet define
      endfor
    endif

    if has_key(s:loaded_columns, column)
      call add(columns, s:loaded_columns[column])
    endif
  endfor

  return columns
endfunction"}}}

function! vimfiler#init#_start(path, ...) "{{{
  if vimfiler#util#is_cmdwin()
    call vimfiler#util#print_error(
          \ '[vimfiler] Command line buffer is detected!')
    call vimfiler#util#print_error(
          \ '[vimfiler] Please close command line buffer.')
    return
  endif

  let path = a:path
  if vimfiler#util#is_win_path(path)
    let path = vimfiler#util#substitute_path_separator(
          \ fnamemodify(vimfiler#util#expand(path), ':p'))
  endif

  let context = vimfiler#initialize_context(get(a:000, 0, {}))
  if &l:modified && !&l:hidden
    " Split automatically.
    let context.split = 1
  endif

  if context.toggle && !context.create
    if vimfiler#mappings#close(context.buffer_name)
      return
    endif
  endif

  if !context.create
    " Search vimfiler buffer.
    for bufnr in filter(insert(range(1, bufnr('$')), bufnr('%')),
          \ "bufloaded(v:val) &&
          \ getbufvar(v:val, '&filetype') ==# 'vimfiler'")
      let vimfiler = getbufvar(bufnr, 'vimfiler')
      if type(vimfiler) == type({})
            \ && vimfiler.context.profile_name ==# context.profile_name
            \ && (!exists('t:unite_buffer_dictionary')
            \      || has_key(t:unite_buffer_dictionary, bufnr))
            \ && (!context.invisible || bufwinnr(bufnr) < 0)
        call vimfiler#init#_switch_vimfiler(bufnr, context, path)
        return
      endif

      unlet vimfiler
    endfor
  endif

  call s:create_vimfiler_buffer(path, context)
endfunction"}}}
function! vimfiler#init#_switch_vimfiler(bufnr, context, directory) "{{{
  let search_path = fnamemodify(bufname('%'), ':p')

  let context = vimfiler#initialize_context(a:context)
  if !context.tab
    let context.alternate_buffer = bufnr('%')
  endif

  if bufwinnr(a:bufnr) < 0
    if context.split
      execute context.direction
            \ (context.horizontal ? 'split' : 'vsplit')
    endif

    execute 'buffer' . a:bufnr
  else
    " Move to vimfiler window.
    execute bufwinnr(a:bufnr).'wincmd w'
  endif

  call vimfiler#handler#_event_bufwin_enter(a:bufnr)

  let b:vimfiler.context = extend(b:vimfiler.context, context)
  call vimfiler#set_current_vimfiler(b:vimfiler)
  let b:vimfiler.prompt_linenr =
        \ (b:vimfiler.context.explorer) ?  0 :
        \ (b:vimfiler.context.status)   ?  2 : 1

  let directory = vimfiler#util#substitute_path_separator(
        \ a:directory)

  " Set current directory.
  if directory != ''
    if directory =~ ':'
      " Parse path.
      let ret = vimfiler#parse_path(directory)
      let b:vimfiler.source = ret[0]
      let directory = join(ret[1:], ':')
    endif

    call vimfiler#mappings#cd(directory)
  endif

  if a:context.find
    call vimfiler#mappings#search_cursor(
          \ substitute(vimfiler#helper#_get_cd_path(
          \ search_path), '/$', '', ''))
  endif

  if a:context.double
    " Create another vimfiler.
    call vimfiler#mappings#create_another_vimfiler()
    wincmd p
  endif

  call vimfiler#view#_force_redraw_all_vimfiler()

  if !context.focus
    if winbufnr(winnr('#')) > 0
      wincmd p
    else
      execute bufwinnr(a:context.vimfiler__prev_bufnr).'wincmd w'
    endif
  endif
endfunction"}}}
function! s:create_vimfiler_buffer(path, context) "{{{
  let search_path = fnamemodify(bufname('%'), ':p')
  let path = a:path
  if path == ''
    " Use current directory.
    let path = vimfiler#util#substitute_path_separator(getcwd())
  endif

  let context = a:context

  if context.project
    let path = vimfiler#util#path2project_directory(path)
  endif

  if &l:modified && !&l:hidden
    " Split automatically.
    let context.split = 1
  endif

  " Create new buffer name.
  let prefix = 'vimfiler:'
  let prefix .= context.profile_name

  let postfix = vimfiler#init#_get_postfix(prefix, 1)

  let bufname = prefix . postfix

  " Set buffer_name.
  let context.profile_name = context.buffer_name
  let context.buffer_name = bufname

  if context.split
    execute context.direction
          \ (context.horizontal ? 'split' : 'vsplit')
  endif

  if context.tab
    noautocmd tabnew
  endif

  " Save swapfile option.
  let swapfile_save = &swapfile

  try
    set noswapfile
    let loaded = s:manager.open(bufname, 'silent edit')
  finally
    let &g:swapfile = swapfile_save
  endtry

  if !loaded
    call vimshell#echo_error(
          \ '[vimfiler] Failed to open Buffer "'. bufname .'".')
    return
  endif

  let context.path = path
  " echomsg path

  call vimfiler#handler#_event_handler('BufReadCmd', context)

  call vimfiler#handler#_event_bufwin_enter(bufnr('%'))

  if context.find
    call vimfiler#mappings#search_cursor(
          \ substitute(vimfiler#helper#_get_cd_path(
          \ search_path), '/$', '', ''))
  endif

  if !context.focus
    if winbufnr(winnr('#')) > 0
      wincmd p
    else
      execute bufwinnr(a:context.vimfiler__prev_bufnr).'wincmd w'
    endif
  endif
endfunction"}}}

function! vimfiler#init#_default_settings() "{{{
  call s:buffer_default_settings()

  " Set autocommands.
  augroup vimfiler "{{{
    autocmd BufEnter,WinEnter,BufWinEnter <buffer>
          \ call vimfiler#handler#_event_bufwin_enter(expand('<abuf>'))
    autocmd BufLeave,WinLeave,BufWinLeave <buffer>
          \ call vimfiler#handler#_event_bufwin_leave(expand('<abuf>'))
    autocmd CursorMoved <buffer>
          \ call vimfiler#handler#_event_cursor_moved()
    autocmd FocusGained <buffer>
          \ call vimfiler#view#_force_redraw_all_vimfiler()
    autocmd VimResized <buffer>
          \ call vimfiler#view#_redraw_all_vimfiler()
  augroup end"}}}
endfunction"}}}

function! s:buffer_default_settings() "{{{
  setlocal buftype=nofile
  setlocal noswapfile
  setlocal noreadonly
  setlocal nowrap
  setlocal nospell
  setlocal bufhidden=hide
  setlocal nolist
  setlocal foldcolumn=0
  setlocal nofoldenable
  setlocal nowrap
  setlocal nomodifiable
  setlocal nomodified
  if has('netbeans_intg') || has('sun_workshop')
    setlocal noautochdir
  endif
  if exists('&colorcolumn')
    setlocal colorcolumn=
  endif

  if has('conceal')
    setlocal conceallevel=3
    setlocal concealcursor=nvc
  endif

  if vimfiler#get_context().explorer
    setlocal nobuflisted
  endif
endfunction"}}}

function! vimfiler#init#_get_postfix(prefix, is_create) "{{{
  let buffers = get(a:000, 0, range(1, bufnr('$')))
  let buflist = vimfiler#util#sort_by(filter(map(buffers,
        \ 'bufname(v:val)'), 'stridx(v:val, a:prefix) >= 0'),
        \ "str2nr(matchstr(v:val, '\\d\\+$'))")
  if empty(buflist)
    return ''
  endif

  let num = matchstr(buflist[-1], '@\zs\d\+$')
  return num == '' && !a:is_create ? '' :
        \ '@' . (a:is_create ? (num + 1) : num)
endfunction"}}}
function! vimfiler#init#_get_filetype(file) "{{{
  let ext = tolower(a:file.vimfiler__extension)

  if (vimfiler#util#is_windows() && ext ==? 'LNK')
        \ || get(a:file, 'vimfiler__ftype', '') ==# 'link'
    " Symbolic link.
    return '[L]'
  elseif a:file.vimfiler__is_directory
    " Directory.
    return '[D]'
  elseif has_key(g:vimfiler_extensions.text, ext)
    " Text.
    return '[T]'
  elseif has_key(g:vimfiler_extensions.image, ext)
    " Image.
    return '[I]'
  elseif has_key(g:vimfiler_extensions.archive, ext)
    " Archive.
    return '[A]'
  elseif has_key(g:vimfiler_extensions.multimedia, ext)
    " Multimedia.
    return '[M]'
  elseif a:file.vimfiler__filename =~ '^\.'
        \ || has_key(g:vimfiler_extensions.system, ext)
    " System.
    return '[S]'
  elseif a:file.vimfiler__is_executable
    " Execute.
    return '[X]'
  else
    " Others filetype.
    return '   '
  endif
endfunction"}}}
function! vimfiler#init#_get_datemark(file) "{{{
  let time = localtime() - a:file.vimfiler__filetime
  if time < 86400
    " 60 * 60 * 24
    return '!'
  elseif time < 604800
    " 60 * 60 * 24 * 7
    return '#'
  else
    return '~'
  endif
endfunction"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker

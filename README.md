# Vimfiler
Powerful file explorer implemented by Vim script

## Introduction
vimfiler is a powerful file explorer(filer) written by Vim script.

## Usage
To run vimfiler, execute this command.

	:VimFiler

If you set `g:vimfiler_as_default_explorer` to 1, vimfiler behaves as default
explorer like netrw.

	:let g:vimfiler_as_default_explorer = 1

vimfiler needs unite.vim
http://github.com/Shougo/unite.vim

Please install unite.vim Ver.3.0(or later) before use vimfiler.

Note: To use 2GB(>) files in vimfiler, vimfiler require +lua interface.

## Screen shots

vimfiler standard operations
----------------------------
![Vimfiler standard operations](https://f.cloud.github.com/assets/214488/657681/c40265e6-d56f-11e2-96fd-03d01f10cc4e.gif)

vimfiler explorer feature(like NERDTree)
----------------------------------------
![Vimfiler explorer](https://f.cloud.github.com/assets/214488/657685/95011fc4-d571-11e2-9934-159196cf9e59.gif)

vimfiler dark theme
----------------------------
![Vimfiler dark theme](https://cloud.githubusercontent.com/assets/147918/3933094/412cc0e0-2478-11e4-902e-63b658f04d81.png)

## What are some of the advantages vs other file browsers?

Some VimFiler advantages/differences are:

- Integration with [unite](https://github.com/Shougo/unite.vim)
- Integration with [vimshell](https://github.com/Shougo/vimshell.vim)
- Many customization options
- External sources(for example, [unite-ssh](https://github.com/Shougo/unite-ssh))
- More options(see |vimfiler-options|)
- Fast(if you use |if_lua| enabled Vim)
- Column customization
- Double screen file explorer

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

Note: To use 4GB(>) files in vimfiler, vimfiler require +python interface.


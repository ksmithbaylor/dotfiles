let mapleader = '\'
let maplocalleader = ','

" Comment wrap handling and visual line
set colorcolumn=81
set textwidth=80
set formatoptions=tcqjn1

" Search options
set inccommand=split
set ignorecase
set smartcase
set showmatch

" Tab handling
set tabstop=2                 " Width of a tab character
set softtabstop=2             " Number of spaces per tabstop
set shiftwidth=0              " Use tabstop value
set expandtab                 " Uses spaces in place of tab characters
set list                      " invisible characters
set listchars=tab:▸\

" Miscellaneous
set scrolloff=10              " Scroll before the cursor reaches top/bottom
set wildmode=list:longest     " List as many possibilities as possible
set cursorline                " Highlight the current line
set number                    " Display absolute line numbers

" When saving a session, only save certain things
set ssop=blank,buffers,curdir,help,tabpages

" Allow mouse interaction
set mouse=nicr

" Use zsh in terminals and background commands
set shell=/usr/local/bin/zsh

runtime plugins.vim
runtime mappings.vim
runtime colors.vim
runtime statusline.lua


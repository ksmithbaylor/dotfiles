" Set leader keys
let mapleader = '\\'
let maplocalleader = ','

" General options to make things better
set nocompatible                  " Don't use old vi-era compatibility settings
set encoding=utf-8                " Default encoding is UTF-8
set scrolloff=1                   " Don't let the cursor get to the edge
set autoindent                    " Start new lines at the same indent level
set showcmd                       " Shows extra info about the current command
set hidden                        " Hides buffers when they are abandoned
set wildmenu                      " Tab-completion of menu options
set wildmode=list:longest         " List as many possibilities as possible
set visualbell                    " Flash screen instead of beeping for bell
set cursorline                    " Highlight the current line
set ttyfast                       " Improves smoothness in fast terminals
set backspace=indent,eol,start    " Not sure what this does, but I trust him
set laststatus=2                  " Put a statusline in every buffer
set number                        " Display the absolute line number as well
set colorcolumn=81                " Put line after 80 columns
set cinkeys-=0#                   " Don't force # directives to column 0 (OpenMP)
set wrap
set textwidth=80
set formatoptions=qrn1
set ignorecase
set smartcase
set gdefault
set incsearch
set showmatch
set hlsearch
set tabstop=2      " Width of a tab character
set shiftwidth=2   "
set softtabstop=2  " Number of spaces per tabstop
set expandtab      " Uses spaces in place of tab characters
set list               " invisible characters
set listchars=tab:▸\

" Makes Vim use the same zshrc so aliases are available in shell commands
set shell=/bin/bash\ --rcfile\ ~/.bashrc\ -i

" When saving a session, only save certain things
set ssop=blank,buffers,curdir,help,tabpages

" Enable mouse movements
set mouse=nicr

" Recommended by COC readme
set cmdheight=2                   " Better display for messages
set shortmess+=c
set signcolumn=yes

call plug#begin()

" General plugins
Plug 'oxfist/night-owl.nvim'
Plug 'nvim-lualine/lualine.nvim'
Plug 'nvim-tree/nvim-tree.lua'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'preservim/nerdcommenter'
Plug 'nanozuki/tabby.nvim'
Plug 'Asheq/close-buffers.vim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-endwise'
Plug 'jiangmiao/auto-pairs'
Plug 'AndrewRadev/splitjoin.vim'
Plug 'godlygeek/tabular'
Plug 'vim-scripts/loremipsum'
Plug 'benmills/vimux'
Plug 'janko-m/vim-test'

" Language-specific
Plug 'fatih/vim-go', { 'for': 'go', 'do': ':GoUpdateBinaries' }
Plug 'gleam-lang/gleam.vim', { 'for': 'gleam' }
Plug 'mracos/mermaid.vim', { 'for': 'mermaid' }
Plug 'bhurlow/vim-parinfer', { 'for': 'lisp' }
Plug 'rust-lang/rust.vim', { 'for': 'rust' }
Plug 'styled-components/vim-styled-components', { 'branch': 'main' }

call plug#end()

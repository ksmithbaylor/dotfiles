call plug#begin()

" General plugins
Plug 'oxfist/night-owl.nvim'
Plug 'nvim-lualine/lualine.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.2' }
Plug 'nvim-tree/nvim-tree.lua'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
" Plug 'hrsh7th/cmp-buffer'
" Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-nvim-lsp-signature-help'
Plug 'sbdchd/neoformat'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'L3MON4D3/LuaSnip'
Plug 'hrsh7th/nvim-cmp'
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
" Plug 'darrikonn/vim-gofmt', { 'for': 'go' }
Plug 'gleam-lang/gleam.vim', { 'for': 'gleam' }
Plug 'mracos/mermaid.vim', { 'for': 'mermaid' }
Plug 'bhurlow/vim-parinfer', { 'for': 'lisp' }
Plug 'rust-lang/rust.vim', { 'for': 'rust' }
Plug 'styled-components/vim-styled-components', { 'branch': 'main' }

call plug#end()

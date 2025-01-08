function! BuildComposer(info)
  if a:info.status != 'unchanged' || a:info.force
    if has('nvim')
      !cargo build --release --locked
    else
      !cargo build --release --locked --no-default-features --features json-rpc
    endif
  endif
endfunction

call plug#begin()

" General plugins
Plug 'oxfist/night-owl.nvim'
Plug 'stevedylandev/flexoki-nvim'
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
Plug 'github/copilot.vim'
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
Plug 'mrjones2014/dash.nvim', { 'do': 'make install' }
Plug 'euclio/vim-markdown-composer', { 'do': function('BuildComposer') }

" Language-specific
" Plug 'darrikonn/vim-gofmt', { 'for': 'go' }
Plug 'gleam-lang/gleam.vim', { 'for': 'gleam' }
Plug 'mracos/mermaid.vim', { 'for': 'mermaid' }
Plug 'bhurlow/vim-parinfer', { 'for': 'lisp' }
Plug 'rust-lang/rust.vim', { 'for': 'rust' }
Plug 'styled-components/vim-styled-components', { 'branch': 'main' }

" Java and deps
" Plug 'nvim-java/lua-async-await'
" Plug 'nvim-java/nvim-java-refactor'
" Plug 'nvim-java/nvim-java-core'
" Plug 'nvim-java/nvim-java-test'
" Plug 'nvim-java/nvim-java-dap'
" Plug 'MunifTanjim/nui.nvim'
" Plug 'neovim/nvim-lspconfig'
" Plug 'mfussenegger/nvim-dap'
" Plug 'JavaHello/spring-boot.nvim', { 'commit': '218c0c26c14d99feca778e4d13f5ec3e8b1b60f0' }
" Plug 'williamboman/mason.nvim'
" Plug 'nvim-java/nvim-java', { 'for': 'java' }

call plug#end()

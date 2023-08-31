call plug#begin()

Plug 'preservim/nerdtree'
Plug 'preservim/nerdcommenter'
Plug 'oxfist/night-owl.nvim'
Plug 'nvim-lualine/lualine.nvim'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'tpope/vim-fugitive'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'ryanoasis/vim-devicons'

call plug#end()

" NERDTree
let NERDTreeHighlightCursorline = 0
let g:webdevicons_conceal_nerdtree_brackets = 1
autocmd FileType nerdtree syntax match hideBracketsInNerdTree "\]" contained conceal containedin=ALL
autocmd FileType nerdtree syntax match hideBracketsInNerdTree "\[" contained conceal containedin=ALL
autocmd FileType nerdtree setlocal conceallevel=3
autocmd FileType nerdtree setlocal concealcursor=nvic

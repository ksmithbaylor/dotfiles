Plug 'tpope/vim-speeddating'

let g:speeddating_formats = [["%a %h %d %Y",0,0]]

nmap <silent><leader>di :normal yyP<CR>:normal A<Space><CR>:normal 015lD0<C-a><CR>

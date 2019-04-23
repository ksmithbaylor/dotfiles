Plug 'mhinz/vim-grepper'

nnoremap <silent> <leader>f :Grepper -tool rg<CR>
nnoremap <silent> <leader>e :normal *<CR>:Grepper -tool rg -cword -noprompt<CR>

let g:grepper = {}
runtime plugin/grepper.vim

let g:grepper.tools = ['rg']
let g:grepper.rg = {}
let g:grepper.rg.grepprg = 'rg -H --no-heading --smart-case --hidden --vimgrep --glob !.git'
let g:grepper.dir = 'repo,cwd'
let g:grepper.prompt_text = '$t> '

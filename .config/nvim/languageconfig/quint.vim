autocmd FileType quint lua vim.lsp.start({name = 'quint', cmd = {'quint-language-server', '--stdio'}, root_dir = vim.fs.dirname()})
au BufRead,BufNewFile *.qnt  setfiletype quint
au BufNewFile,BufReadPost *.qnt runtime syntax/quint.vim

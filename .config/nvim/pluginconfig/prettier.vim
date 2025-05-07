let g:prettier#autoformat = 1
let g:prettier#autoformat_require_pragma = 0
let g:prettier#exec_cmd_async = 1
let g:prettier#config#config_precedence = 'prefer-file'
autocmd BufWritePre *.sql :PrettierAsync<CR>

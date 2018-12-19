Plug 'sbdchd/neoformat'
  let g:neoformat_c_clangformat = { 'exe': 'clang-format', 'args': ['-style=Google'], 'stdin': 1 }
  let g:neoformat_enabled_c = ['clangformat']
  let g:neoformat_cpp_clangformat = g:neoformat_c_clangformat
  let g:neoformat_enabled_cpp = g:neoformat_enabled_c

Plug 'prettier/vim-prettier'
  let g:prettier#autoformat = 0

Plug 'mhinz/vim-mix-format'
  let g:mix_format_on_save = 0

Plug 'mindriot101/vim-yapf'
  let g:yapf_style = "facebook"

" Assume vim-plug is present and plugins are installed
let should_plug_install=0

" Install vim-plug if it's not already present
if empty(glob('~/.vim/autoload/plug.vim'))
  echo "Downloading vim-plug..."
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  let should_plug_install = 1
endif

" Even if vim-plug is present, install plugins if they are missing
if !isdirectory($HOME."/.vim/plugged")
  let should_plug_install=1
endif

" Initialize plugins
call plug#begin('~/.vim/plugged')

" File tree sidebar
Plug 'scrooloose/nerdtree'
  nnoremap <silent> <C-t> :NERDTreeToggle<CR>
  nnoremap <silent> <leader>nf :NERDTreeFind<CR>
  nnoremap <silent> <leader>nt :NERDTreeToggle<CR>
  let g:NERDTreeCaseSensitiveSort = 1
  let g:NERDTreeSortOrder = ['__tests__', '^index\.js', '^shared', '^[A-Z].*\.js', '\/$', '^\.']
  let g:NERDTreeShowHidden = 1
  let g:NERDTreeMinimalUI = 1
  let g:NERDTreeDirArrows = 1
  let g:NERDTreeCascadeOpenSingleChildDir = 1
  let g:NERDTreeAutoDeleteBuffer = 1
  let g:NERDTreeSortHiddenFirst = 1

" Shows git status of files in file tree
Plug 'Xuyuanp/nerdtree-git-plugin'

" Allows toggling comments with <leader>c<space>
Plug 'scrooloose/nerdcommenter'
  let g:NERDSpaceDelims = 1

" Fuzzy finder, used for file/buffer finding and project searching
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
  set rtp+=~/.fzf
  set rtp+=/usr/local/opt/fzf
  let g:fzf_command_prefix = 'Fzf'
  let g:fzf_layout = { 'down': '~50%' }
  " Search through open buffers
  nnoremap <C-l> :FzfBuffers<CR>
  " Folder search with preview
  nnoremap <C-F> :Ag<CR>
  command! -nargs=* Ag
    \ call fzf#vim#ag(<q-args>, fzf#vim#with_preview('right:50%', '?'))
  " Fuzzy file find with preview
  nnoremap <C-p> :FF -c -o --directory<CR>
  command! -nargs=* FF
    \ call fzf#vim#gitfiles(<q-args>, fzf#vim#with_preview('right:50%', '?'))

" Git integration
Plug 'tpope/vim-fugitive'

Plug 'sukima/xmledit'
  let g:xmledit_enable_html=1
  function HtmlAttribCallback( xml_tag )
  endfunction
Plug 'itchyny/lightline.vim'
Plug 'jiangmiao/auto-pairs'
  let g:AutoPairsShortcutFastWrap = '<C-W>'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-endwise'
Plug 'godlygeek/tabular'
Plug 'benmills/vimux'
  nnoremap <leader>rn :VimuxPromptCommand<CR>
  nnoremap <leader>rl :VimuxRunLastCommand<CR>
  nnoremap <leader>a :autocmd BufWritePost * :VimuxRunLastCommand<CR>
  nnoremap <leader>x :autocmd! BufWritePost *<CR>
Plug 'ksmithbaylor/tomorrow-theme', { 'rtp': 'vim' }
Plug 'lilydjwg/colorizer'

" Language-specific plugins
Plug 'othree/html5.vim'
  autocmd BufNewFile,BufRead *.ejs set filetype=html
Plug 'neovimhaskell/haskell-vim', { 'for': 'haskell' }
Plug 'vim-ruby/vim-ruby', { 'for': 'ruby' }
Plug 'pangloss/vim-javascript'
  let g:javascript_ignore_javaScriptdoc = 1
Plug 'mxw/vim-jsx'
  let g:jsx_ext_required = 0
Plug 'zaiste/tmux.vim'
Plug 'elmcast/elm-vim'
  " au BufEnter,BufWritePost *.elm ElmMake
Plug 'raichoo/purescript-vim'
Plug 'elixir-lang/vim-elixir'
Plug 'rust-lang/rust.vim'
Plug 'mustache/vim-mustache-handlebars'
Plug 'digitaltoad/vim-pug'

" Linting
Plug 'benekastah/neomake'
  let g:neomake_javascript_enabled_makers = ['eslint']
  " load local eslint in the project root
  " modified from https://github.com/mtscout6/syntastic-local-eslint.vim
  let s:eslint_path = system('PATH=$(npm bin):$PATH && which eslint')
  let g:neomake_javascript_eslint_exe = substitute(s:eslint_path, '^\n*\s*\(.\{-}\)\n*\s*$', '\1', '')
  "let g:neomake_open_list = 2
  nnoremap <leader>l :Neomake<CR>
  autocmd! BufWritePost,BufEnter *.js Neomake

" Formatting
Plug 'sbdchd/neoformat'
  let g:neoformat_c_clangformat = { 'exe': 'clang-format', 'args': ['-style=Google'], 'stdin': 1 }
  let g:neoformat_enabled_c = ['clangformat']
  let g:neoformat_cpp_clangformat = g:neoformat_c_clangformat
  let g:neoformat_enabled_cpp = g:neoformat_enabled_c

Plug 'prettier/vim-prettier'
  let g:prettier#autoformat = 0

" Why not?
Plug 'johngrib/vim-game-code-break', { 'on': 'VimGameCodeBreak' }

" All plugins have been declared. If needed, install them and quit
call plug#end()
if should_plug_install == 1
  :echo "Installing plugins..."
  :silent! PlugInstall
  :echo "Done! Please re-launch.\n"
  :qa
endif

function! ToggleAutoFormatting()
    if !exists('#AutoFormattingPreSave#BufWritePre')
        augroup AutoFormattingPreSave
            autocmd!
            autocmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.graphql Prettier
            autocmd BufWritePre *.cpp,*.hpp,*.c,*.h Neoformat
            autocmd BufWritePost *.elm ElmFormat
        augroup END
        echo 'Auto-formatting on'
    else
        augroup AutoFormattingPreSave
            autocmd!
        augroup END
        echo 'Auto-formatting off'
    endif
endfunction

nnoremap <F4> :call ToggleAutoFormatting()<CR>
silent call ToggleAutoFormatting()

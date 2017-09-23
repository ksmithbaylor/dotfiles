" ------------------------------------------------------------------------------
" === PLUGINS ==================================================================

let should_plug_install=0

if empty(glob('~/.vim/autoload/plug.vim'))
  echo "Downloading vim-plug..."
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  let should_plug_install = 1
endif

if !isdirectory($HOME."/.vim/plugged")
  let should_plug_install=1
endif

" Initialize plugins
call plug#begin('~/.vim/plugged')

" General plugins, applicable for any file
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
Plug 'Xuyuanp/nerdtree-git-plugin', { 'on': 'NERDTreeToggle' }
Plug 'scrooloose/nerdcommenter'
Plug 'jlanzarotta/bufexplorer', { 'on': 'BufExplorer' }
Plug 'fholgado/minibufexpl.vim', { 'on': 'MBEOpen!' }
  nnoremap <silent><leader>b :MBEOpen!<CR>:MBEFocus<CR>
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
  set rtp+=~/.fzf
  set rtp+=/usr/local/opt/fzf
  let g:fzf_command_prefix = 'Fzf'
  let g:fzf_layout = { 'down': '~40%' }
  nnoremap <C-p> :FzfGitFiles<CR>
  nnoremap <C-s> :FzfAg<CR>
  nnoremap <C-l> :FzfBuffers<CR>
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
Plug 'mileszs/ack.vim'
  let g:ackprg = 'ag --nogroup --nocolor --column'
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
  au BufWritePost *.elm ElmFormat
  au BufEnter,BufWritePost *.elm ElmMake
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
  "autocmd BufWritePre *.js Neoformat
  nnoremap <leader>neo :autocmd BufWritePre * :Neoformat<CR>
  nnoremap <leader>noneo :autocmd! BufWritePre *<CR>

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


" ------------------------------------------------------------------------------
" === GENERAL ==================================================================

" Configure syntax highlighting
syntax enable
colorscheme Tomorrow-Night-Bright

" Change gutter line numbers to be lighter
highlight LineNr      ctermbg=235
highlight LineNr      ctermfg=241

" Put backup and swap files in a central location
silent !mkdir -p $HOME/.vim/swapfiles > /dev/null 2>&1
silent !mkdir -p $HOME/.vim/backup > /dev/null 2>&1
set directory=$HOME/.vim/swapfiles//
set backupdir=$HOME/.vim/backup//

" General options to make things better
set nocompatible                  " Don't use old vi-era compatibility settings
set encoding=utf-8                " Default encoding is UTF-8
set scrolloff=1                   " Don't let the cursor get to the edge
set autoindent                    " Start new lines at the same indent level
set showcmd                       " Shows extra info about the current command
set hidden                        " Hides buffers when they are abandoned
set wildmenu                      " Tab-completion of menu options
set wildmode=list:longest         " List as many possibilities as possible
set visualbell                    " Flash screen instead of beeping for bell
set cursorline                    " Highlight the current line
set ttyfast                       " Improves smoothness in fast terminals
set backspace=indent,eol,start    " Not sure what this does, but I trust him
set laststatus=2                  " Put a statusline in every buffer
set number                        " Display the absolute line number as well
set colorcolumn=81                " Put line after 80 columns
set cinkeys-=0#                   " Don't force # directives to column 0 (OpenMP)
set wrap
set textwidth=80
set formatoptions=qrn1
set ignorecase
set smartcase
set gdefault
set incsearch
set inccommand=split
set showmatch
set hlsearch
set tabstop=2      " Width of a tab character
set shiftwidth=2   "
set softtabstop=2  " Number of spaces per tabstop
set expandtab      " Uses spaces in place of tab characters
set list               " invisible characters
set listchars=tab:▸\

" Makes Vim use the same zshrc so aliases are available in shell commands
set shell=/bin/bash\ --rcfile\ ~/.bashrc\ -i

" When saving a session, only save certain things
set ssop=blank,buffers,curdir,help,tabpages

" Enable mouse movements
set mouse=nicr

if has("nvim")
  set shell=/usr/local/bin/zsh
  tnoremap <Esc> <C-\><C-n>
endif

" Tmux-specific settings for colors and pasting
set t_Co=256
set t_ut=
function! WrapForTmux(s)
  if !exists('$TMUX')
    return a:s
  endif
  let tmux_start = "\<Esc>Ptmux;"
  let tmux_end = "\<Esc>\\"
  return tmux_start . substitute(a:s, "\<Esc>", "\<Esc>\<Esc>", 'g') . tmux_end
endfunction
let &t_SI .= WrapForTmux("\<Esc>[?2004h")
let &t_EI .= WrapForTmux("\<Esc>[?2004l")
function! XTermPasteBegin()
  set pastetoggle=<Esc>[201~
  set paste
  return ""
endfunction
inoremap <special> <expr> <Esc>[200~ XTermPasteBegin()


" ------------------------------------------------------------------------------
" === MAPPINGS =================================================================

" Clear the current search
nnoremap <leader><space> :noh<cr>

" Make Vim handle long lines correctly
nnoremap j gj
nnoremap k gk
nnoremap <Down> gj
nnoremap <Up> gk

" Enable quicker creation and navigation of tabs
nnoremap <leader>] :tabn<CR>
nnoremap <leader>[ :tabp<CR>
nnoremap <leader><CR> :tabnew<CR>
nnoremap <leader>{ :tabm -1<CR>
nnoremap <leader>} :tabm +1<CR>

" Enable 'line bubbling' (requires vim-unimpaired)
nmap <C-k> [e
nmap <C-j> ]e
vmap <C-k> [egv
vmap <C-j> ]egv
inoremap <C-j> <Esc>:m .+1<CR>==gi
inoremap <C-k> <Esc>:m .-2<CR>==gi

" Re-highlight lines in visual mode after indent
vnoremap < <gv
vnoremap > >gv

" A wrapper function to restore the cursor position, window position,
" and last search after running a command.
function! Preserve(command)
  " Save the current cursor position
  let save_cursor = getpos(".")
  " Save the window position
  normal H
  let save_window = getpos(".")
  call setpos('.', save_cursor)

  " Do the business:
  execute a:command

  " Restore the window position
  call setpos('.', save_window)
  normal zt
  " Restore the cursor position
  call setpos('.', save_cursor)
endfunction

" Highlight all of the word under the cursor
nnoremap * :call Preserve('call feedkeys("*N", "n")')<CR>

" Re-indent the whole file
nnoremap <leader>i :call Preserve('normal gg=G')<CR>

" Clear trailing whitespace in the whole file
nnoremap <silent> <leader>ww :%s/\s\+$//<CR>:let @/=''<CR><C-o>

" Splits the window vertically or horizontally and switches to the new one
nnoremap <leader>s <C-w>v<C-w>l
nnoremap <leader>h <C-w>s<C-w>j

" Search by visual selection
vnoremap * y/<C-r>"<CR>N

" Two-column scrollbinding
nnoremap <silent> <leader>vs :<C-u>let @z=&so<CR>:set so=0 noscb<CR>:bo vs<CR>Ljzt:setl scb<CR><C-w>p:setl scb<CR>:let &so=@z<CR>


" ------------------------------------------------------------------------------
" === MORE COMPLEX FEATURES ====================================================

" Highlight trailing whitespace
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd BufRead,InsertLeave * match ExtraWhitespace /\s\+$/
" Set up highlight group & retain through colorscheme changes
highlight ExtraWhitespace ctermbg=red guibg=red
autocmd ColorScheme * highlight ExtraWhitespace ctermbg=red guibg=red
map <silent> <LocalLeader>ws :highlight clear ExtraWhitespace<CR>

" Automatically strip trailing blank lines on all files
function! TrimEndLines()
  let save_cursor = getpos(".")
  :silent! %s#\($\n\s*\)\+\%$##
  call setpos('.', save_cursor)
endfunction
au BufWritePre * call TrimEndLines()

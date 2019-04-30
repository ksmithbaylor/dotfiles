" Configure syntax highlighting (Credit joshdick)

" Use 24-bit (true-color) mode in Vim/Neovim when outside tmux.
" If you're using tmux version 2.2 or later, you can remove the outermost $TMUX check and use tmux's 24-bit color support.
" (see < http://sunaku.github.io/tmux-24bit-color.html#usage > for more information.)
if (has("nvim"))
  "For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
  let $NVIM_TUI_ENABLE_TRUE_COLOR=1
endif

let &t_8f="\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b="\<Esc>[48;2;%lu;%lu;%lum"
set termguicolors

syntax enable

let g:one_allow_italics = 1 " I love italic for comments
set background=dark
colorscheme OceanicNext
highlight link jsComment Comment
highlight link vimComment Comment
highlight link elmLineComment Comment
highlight Comment cterm=italic

" Change gutter line numbers to be lighter
highlight LineNr      ctermbg=235
highlight LineNr      ctermfg=241

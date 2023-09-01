let $NVIM_TUI_ENABLE_TRUE_COLOR=1
set termguicolors

syntax enable
syntax sync fromstart

colorscheme night-owl

" Tweak editor colors
hi LineNr guifg=#2b404a ctermfg=238 guibg=#011627 ctermbg=233 gui=NONE cterm=NONE
hi ColorColumn guibg=#112630 ctermbg=235 gui=NONE cterm=NONE

" Tweak tree colors
hi NvimTreeNormal guibg=#01101d
hi NvimTreeNormalNC guibg=#01101d

let g:kjs_transparent = 0

echo 

function! ToggleTransparency()
  if (g:kjs_transparent == 1)
    highlight Normal guibg='#282c34'
    " highlight ColorColumn guibg='#2c323c'
    " highlight CursorColumn guibg='#2c323c'
    " highlight CursorLine guibg='#2c323c'
    let g:kjs_transparent = 0
  else
    highlight Normal guibg=none
    " highlight ColorColumn guibg=none
    " highlight CursorColumn guibg=none
    " highlight CursorLine guibg=none
    let g:kjs_transparent = 1
  endif
endfunction

nnoremap <F12> :call ToggleTransparency()<CR>

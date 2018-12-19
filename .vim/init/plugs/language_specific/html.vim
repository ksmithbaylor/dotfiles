Plug 'othree/html5.vim'
  autocmd BufNewFile,BufRead *.ejs set filetype=html

Plug 'sukima/xmledit'
  let g:xmledit_enable_html=1
  function! HtmlAttribCallback( xml_tag )
  endfunction

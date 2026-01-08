vim.cmd [[
  set foldmethod=expr
  set foldexpr=nvim_treesitter#foldexpr()
  autocmd BufReadPost,FileReadPost * normal zR
]]

-- require('nvim-treesitter.configs').setup {
--   ensure_installed = "all",
-- 
--   ignore_install = { "wing" },
-- 
--   highlight = {
--     enable = true
--   },
-- 
--   indent = {
--     enable = true
--   }
-- }

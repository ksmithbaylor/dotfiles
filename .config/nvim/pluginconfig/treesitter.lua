require('nvim-treesitter.configs').setup {
  ensure_installed = "all",

  ignore_install = { "wing" },

  highlight = {
    enable = true
  }
}

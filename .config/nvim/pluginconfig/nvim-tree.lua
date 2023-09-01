local nvim_tree_api = require "nvim-tree.api"

local function on_attach_nvim_tree(bufnr)
  local function opts(desc)
    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  nvim_tree_api.config.mappings.default_on_attach(bufnr)
  vim.keymap.set("n", "<C-t>", nvim_tree_api.tree.close, opts("Close Tree"))
  vim.keymap.set("n", "t", nvim_tree_api.node.open.tab, opts("Open in new tab"))
end

require("nvim-tree").setup({
  on_attach = on_attach_nvim_tree,
  sort = {
    sorter = "case_sensitive"
  },
  --view = {
    --float = {
      --enable = true,
      --open_win_config = {
        --relative = "editor",
        --border = "rounded",
        --width = 30,
        --height = 40,
        --row = 1,
        --col = 1
      --}
    --}
  --},
  filters = {
    git_ignored = false,
    dotfiles = false,
    git_clean = false,
    no_buffer = false,
    custom = {},
    exclude = {},
  }
})

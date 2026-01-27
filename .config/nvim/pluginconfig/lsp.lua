-- Set default root markers for all clients
vim.lsp.config('*', {
  root_markers = {
    '.git'
  },
})

local servers = {
  -- go install golang.org/x/tools/gopls@latest
  'gopls',

  -- go install github.com/nametake/golangci-lint-langserver@latest
  -- go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
  'golangci_lint_ls',

  -- yarn global add typescript typescript-language-server
  -- 'ts_ls',

  -- mise install deno
  'denols',

  -- Installed by default with rustup
  'rust_analyzer',

  -- yarn global add pyright
  'pyright',

  -- yarn global add vscode-langservers-extracted
  'cssls',
  'jsonls',
  'html',

  -- yarn global add @microsoft/compose-language-service
  'docker_compose_language_service',

  -- yarn global add dockerfile-language-server-nodejs
  'dockerls',

  -- yarn global add graphql-language-service-cli
  'graphql',

  -- gem install solargraph
  'solargraph',

  -- gem install rubocop
  'rubocop',

  -- yarn global add @ignored/solidity-language-server
  'solidity_ls_nomicfoundation',
}

vim.g.markdown_fenced_languages = {
  "ts=typescript"
}

-- require('mason').setup({
--   registries = {
--     'github:nvim-java/mason-registry',
--     'github:mason-org/mason-registry'
--   }
-- })
--
-- require('java').setup()

for _, lsp in ipairs(servers) do
  local capabilities = require('cmp_nvim_lsp').default_capabilities()

  if lsp == 'cssls' or lsp == 'jsonls' or lsp == 'html' then
    capabilities.textDocument.completion.completionItem.snippetSupport = true
  end

  params = { capabilities = capabilities }

  if lsp == 'ts_ls' then
    params = {
      capabilities = capabilities,
      root_markers = { "package.json" },
      single_file_support = false
    }
  end

  if lsp == 'denols' then
    params = {
      capabilities = capabilities,
      root_markers = { "deno.json", "deno.jsonc" }
    }
  end

  vim.lsp.config(lsp, params)
  vim.lsp.enable(lsp)
end

-- General LSP mappings
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<space>f', function()
      vim.lsp.buf.format { async = true }
    end, opts)
  end,
})

-- Errors and diagnostics
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[e', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']e', vim.diagnostic.goto_next)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

local has_words_before = function()
  unpack = unpack or table.unpack
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local cmp = require('cmp')

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },

  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'nvim_lsp_signature_help' },
  }),

  mapping = cmp.mapping.preset.insert({
    ['<C-e>'] = cmp.mapping.abort(),
    ['<Down>'] = cmp.mapping.select_next_item {
      behavior = cmp.SelectBehavior.Select
    },
    ['<Up>'] = cmp.mapping.select_prev_item {
      behavior = cmp.SelectBehavior.Select
    },
    ['<C-p>'] = cmp.mapping.scroll_docs(-4),
    ['<C-n>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true
    },
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { "i", "s" }),

    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  })
})

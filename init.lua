require'config.lazy'

require'nvim-treesitter.configs'.setup {
  ensure_installed = "all",     
  highlight = {
    enable = true              
  },
}

local cmp = require'cmp'
cmp.setup({
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
      -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
      -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
      -- vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)

      -- For `mini.snippets` users:
      -- local insert = MiniSnippets.config.expand.insert or MiniSnippets.default_insert
      -- insert({ body = args.body }) -- Insert at cursor
      -- cmp.resubscribe({ "TextChangedI", "TextChangedP" })
      -- require("cmp.config").set_onetime({ sources = {} })
    end,
  },
  window = {
    -- completion = cmp.config.window.bordered(),
    -- documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<Tab>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    -- { name = 'vsnip' }, -- For vsnip users.
    { name = 'luasnip' }, -- For luasnip users.
    -- { name = 'ultisnips' }, -- For ultisnips users.
    -- { name = 'snippy' }, -- For snippy users.
  }, {
    { name = 'buffer' },
  })
})

-- Set up lspconfig.
local capabilities = require('cmp_nvim_lsp').default_capabilities()
require('lspconfig')['gopls'].setup {
  capabilities = capabilities
}

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.opt.cursorline = true
vim.opt.number = true
vim.opt.guicursor = "n-v-i-c:block-Cursor"
vim.opt.scrolloff = 10

-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

-- Decrease update time
vim.opt.updatetime = 250

require('telescope').setup({
	defaults = {
		file_ignore_patterns = {
			  '.git/',
			  '*.asset',
			  '*.meta',
		},
	},
})

local builtin = require'telescope.builtin'
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

vim.g.neoterm_autoscroll = 1
vim.g.neoterm_size = 15
vim.g.neoterm_default_mod = 'botright horizontal'

vim.g.netrw_list_hide = '.git/, *.asset, *.meta'
vim.g.netrw_hide = 1

require('custom.ezbazel')

vim.api.nvim_create_user_command('EzBazel', function (opts)
	local kind_pattern
	local bazel_args
	if opts.args == "build" then
		kind_pattern = ".*"
		bazel_args = ""
	end
	if opts.args == "test" then
		kind_pattern = "test"
		bazel_args = "--test_output=all"
	end
	if opts.args == "run" then
		kind_pattern = "binary"
		bazel_args = ""
	end
	bazel_target_picker(kind_pattern, function (selection)
		local command = string.format("bazel %s %s %s", opts.args, bazel_args, selection)
		print(command)	
		vim.api.nvim_command(string.format(":T %s", command))
	end)
end, {
	nargs = '?',
	desc = 'Simple tool to find and perform actions with a bazel target'
})

vim.keymap.set('n', '<leader>bb', ':EzBazel build<CR>', { desc = 'Bazel build' })
vim.keymap.set('n', '<leader>br', ':EzBazel run<CR>', { desc = 'Bazel run' })
vim.keymap.set('n', '<leader>bt', ':EzBazel test<CR>', { desc = 'Bazel test' })


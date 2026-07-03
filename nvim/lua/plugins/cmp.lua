return {
  {
    "hrsh7th/nvim-cmp",
    event        = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
      "L3MON4D3/LuaSnip",
      "rafamadriz/friendly-snippets",
      "windwp/nvim-autopairs",
    },
    config = function()
      local cmp      = require("cmp")
      local luasnip  = require("luasnip")
      local autopair = require("nvim-autopairs.completion.cmp")
      local has_copilot, suggestion = pcall(require, "copilot.suggestion")

      require("luasnip.loaders.from_vscode").lazy_load()
      cmp.event:on("confirm_done", autopair.on_confirm_done())

      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"]   = cmp.mapping.scroll_docs(-4),
          ["<C-f>"]   = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"]   = cmp.mapping.abort(),
          ["<CR>"]    = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if has_copilot and suggestion.is_visible() then
              suggestion.accept()
              return
            end
            fallback()
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip"  },
        }, {
          { name = "buffer" },
          { name = "path"   },
        }),
      })
    end,
  },
}

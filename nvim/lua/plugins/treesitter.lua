return {
  {
    "nvim-treesitter/nvim-treesitter",
    build  = ":TSUpdate",
    event  = { "BufReadPost", "BufNewFile" },
    opts   = {
      ensure_installed = {
        "bash", "fish", "go", "gomod", "rust", "dart",
        "lua", "javascript", "typescript", "tsx", "swift",
        "dockerfile", "markdown", "markdown_inline",
        "json", "yaml", "toml",
      },
      highlight               = { enable = true },
      indent                  = { enable = true },
      incremental_selection   = {
        enable = true,
        keymaps = {
          init_selection    = "gnn",
          node_incremental  = "grn",
          scope_incremental = "grc",
          node_decremental  = "grm",
        },
      },
    },
  },
}

